/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'color-green': '#10b981',
        'color-white': '#ffffff',
      }
    },
  },
  plugins: [],
}