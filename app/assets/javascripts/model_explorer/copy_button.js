class CopyButton {
  constructor({copyButtonId, targetId}) {
    this.copyButton = document.getElementById(copyButtonId);
    this.target = document.getElementById(targetId);
  }

  initialize() {
    this.copyButton.addEventListener('click', () => {
      const textarea = document.createElement('textarea');
      const copyText = this.copyButton.textContent;

      textarea.value = this.target.textContent;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);

      this.copyButton.textContent = this.copyButton.dataset.text;

      setTimeout(() => {
        this.copyButton.textContent = copyText;
      }, 3000);
    });
  }
}
