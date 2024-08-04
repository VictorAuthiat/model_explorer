class CopyButton {
  constructor({copyButtonId, targetId}) {
    this.copyButton = document.getElementById(copyButtonId);
    this.target = document.getElementById(targetId);
  }

  initialize() {
    this.copyButton.addEventListener('click', () => {
      const textarea = document.createElement('textarea');
      const copyButtonHtml = this.copyButton.innerHTML;

      textarea.value = this.target.textContent;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);

      this.copyButton.textContent = this.copyButton.dataset.text;

      setTimeout(() => {
        this.copyButton.innerHTML = copyButtonHtml;
      }, 1000);
    });
  }
}
