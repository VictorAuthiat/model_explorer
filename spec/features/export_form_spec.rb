require "rails_helper"

RSpec.feature "Export form", type: :feature do
  before { visit "/model_explorer/models" }

  let(:submit_button) { find("#export-form input[type=submit]") }
  let(:model_select)  { find("#association-select-ts-control") }
  let(:user_option)   { find('div[data-value="User"]') }
  let(:copy_button)   { find("#copy-record-details") }
  let(:json_data_pre) { find("#json-pre") }

  let!(:user) do
    User.create!(email: "foo@bar.baz", password: "password")
  end

  let!(:user_post) do
    Post.create!(title: "foo", content: "bar", user: user)
  end

  context "when user submits the form without selecting a model and without record id" do
    before do
      submit_button.click
    end

    it "shows the model and record id validation errors" do
      expect(page).to have_css(".invalid-feedback", count: 2)
    end
  end

  context "when user submits the form without selecting a model" do
    before do
      fill_in "record_id", with: 1
      submit_button.click
    end

    it "shows the model validation error" do
      expect(page).to have_css(".invalid-feedback", count: 1)
    end
  end

  context "when user select the user model" do
    before do
      model_select.click
      user_option.click
    end

    it "shows the user association select" do
      expect(page).to have_css("#associations-select-user-ts-control")
    end

    context "when user changes the model" do
      before do
        find("#association-select-ts-control").click
        find('div[data-value="Post"]').click
      end

      it "removes the user association select" do
        expect(page).not_to have_css("#associations-select-user-ts-control")
      end

      it "shows the post association select" do
        expect(page).to have_css("#associations-select-post-ts-control")
      end
    end

    context "when submit the form without record id" do
      before { submit_button.click }

      it "shows the record id validation error" do
        expect(page).to have_css(".invalid-feedback", count: 1)
      end
    end

    context "when submit the form with an existing record id" do
      before do
        fill_in "record_id", with: user.id
        submit_button.click
      end

      it "shows the user export", :aggregate_failures do
        expect(json_data_pre).to be_visible
        expect(JSON.parse(json_data_pre.text)).to match({
          "model" => "User",
          "attributes" => hash_including(
            "id" => user.id,
            "email" => user.email,
            "encrypted_password" => "---FILTERED---"
          ),
          "associations" => []
        })
      end

      context "and the user clicks the 'Copy' button" do
        before do
          copy_button.click

          page.driver.browser.execute_cdp(
            "Browser.setPermission",
            origin: page.server_url,
            permission: {name: "clipboard-read"},
            setting: "granted"
          )
        end

        after do
          page.evaluate_script("navigator.clipboard.writeText('')")
          page.driver.browser.execute_cdp(
            "Browser.setPermission",
            origin: page.server_url,
            permission: {name: "clipboard-read"},
            setting: "denied"
          )
        end

        it "copies the JSON data to the clipboard", :aggregate_failures do
          clip_text = page.evaluate_async_script(
            "navigator.clipboard.readText().then(arguments[0])"
          )

          expect(copy_button).to have_content("Copied!")
          expect(clip_text).to eq(json_data_pre.text)
        end
      end
    end

    context "when submit the form with a non-existing record id" do
      before do
        fill_in "record_id", with: 0
        submit_button.click
      end

      it "shows the record not found error" do
        expect(json_data_pre).to be_visible
        expect(json_data_pre).to have_content("Couldn't find User with 'id'=0")
      end
    end

    context "when user select the posts association" do
      before do
        find("#associations-select-user-ts-control").click
        find('div[data-value="posts"]').click
      end

      it "shows the user posts association select" do
        expect(page).to have_css("#associations-select-user-posts-ts-control")
      end

      context "and removes the posts association" do
        before do
          find("div[data-value='posts']").click
          page.send_keys(:delete)
        end

        it "removes the user posts association select" do
          expect(page).not_to have_css("#associations-select-user-posts-ts-control")
        end
      end

      context "and submits the form with a post related to the user" do
        it "shows the user export with the post" do
          fill_in "record_id", with: user.id
          submit_button.click

          aggregate_failures do
            expect(json_data_pre).to be_visible
            expect(JSON.parse(json_data_pre.text)).to match({
              "model" => "User",
              "attributes" => hash_including(
                "id" => user.id,
                "email" => user.email,
                "encrypted_password" => "---FILTERED---"
              ),
              "associations" => [{
                "name" => "posts",
                "type" => "has_many",
                "scopes" => [],
                "count" => 1,
                "records" => [{
                  "model" => "Post",
                  "attributes" => hash_including(
                    "id" => user_post.id,
                    "title" => user_post.title,
                    "content" => user_post.content
                  ),
                  "associations" => []
                }]
              }]
            })
          end
        end
      end
    end
  end

  describe "Scopes select" do
    context "when user selects the comments association" do
      before do
        model_select.click
        user_option.click
        find("#associations-select-user-ts-control").click
        find('div[data-value="comments"]').click

        user.comments.create!(content: "foo", status: "draft", post: user_post)
        user.comments.create!(content: "bar", status: "published", post: user_post)
      end

      it "shows the scopes select" do
        expect(page).to have_css("#scopes-select-user-comments-ts-control")
      end

      context "and submit with published comments scope" do
        before do
          find("#scopes-select-user-comments-ts-control").click
          find('div[data-value="published"]').click
        end

        it "shows the user export with the published comments" do
          fill_in "record_id", with: user.id
          submit_button.click

          aggregate_failures do
            expect(json_data_pre).to be_visible
            expect(JSON.parse(json_data_pre.text)).to match({
              "model" => "User",
              "attributes" => hash_including(
                "id" => user.id,
                "email" => user.email,
                "encrypted_password" => "---FILTERED---"
              ),
              "associations" => [{
                "name" => "comments",
                "type" => "has_many",
                "scopes" => ["published"],
                "count" => 1,
                "records" => [{
                  "model" => "Comment",
                  "attributes" => hash_including(
                    "content" => "bar",
                    "status" => 1
                  ),
                  "associations" => []
                }]
              }]
            })
          end
        end
      end
    end
  end

  describe "Columns select" do
    context "when user selects the user model" do
      before do
        model_select.click
        user_option.click
      end

      context "and submit with the email column" do
        before do
          find("#columns-select-user-ts-control").click
          find('div[data-value="email"]').click
        end

        it "shows the user export with only the email column and the primary key" do
          fill_in "record_id", with: user.id
          submit_button.click

          aggregate_failures do
            expect(json_data_pre).to be_visible
            expect(JSON.parse(json_data_pre.text)).to match({
              "model" => "User",
              "attributes" => {
                "id" => user.id,
                "email" => user.email
              },
              "associations" => []
            })
          end
        end
      end

      context "and submit with the posts association and the title column" do
        before do
          find("#associations-select-user-ts-control").click
          find('div[data-value="posts"]').click
          find("#columns-select-user-posts-ts-control").click
          find('div[data-value="title"]').click
        end

        it "shows the user export with the posts and only selected columns" do
          fill_in "record_id", with: user.id
          submit_button.click

          aggregate_failures do
            expect(json_data_pre).to be_visible
            expect(JSON.parse(json_data_pre.text)).to match({
              "model" => "User",
              "attributes" => hash_including(
                "id" => user.id,
                "email" => user.email
              ),
              "associations" => [{
                "name" => "posts",
                "type" => "has_many",
                "scopes" => [],
                "count" => 1,
                "records" => [{
                  "model" => "Post",
                  "attributes" => {
                    "id" => user_post.id,
                    "title" => user_post.title
                  },
                  "associations" => []
                }]
              }]
            })
          end
        end
      end
    end
  end
end
