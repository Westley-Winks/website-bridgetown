import "$styles/index.scss"
import "$styles/syntax-highlighting"
import "$javascript/snow-fall"

// import styles from "../**/*.{scss,css}"
// Object.entries(styles).forEach(style => style)

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}"

/* TOC button */
(function () {
  var button = document.getElementById("menu-button");
  if (button) {
    var menu = document.getElementById("tableOfContents");
    button.addEventListener("click", function () {
      var expanded = this.getAttribute("aria-expanded") === "true";
      this.setAttribute("aria-expanded", !expanded);
    });
  }
})();
