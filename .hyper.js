module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 18,

    // font family with optional fallbacks
    fontFamily: '"Fira Code", SauceCodePowerline-Regular, Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: 'rgba(96, 91, 119, 0.9)',

    // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    cursorShape: 'BEAM',

    // color of the text
    foregroundColor: '#a09bb7',

    // terminal background color
    backgroundColor: '#2a2833',

    // border color (window, tabs)
    borderColor: 'hsl(250, 12%, 14%)',

    // custom css to embed in the main window
    css: '',

    // custom css to embed in the terminal window
    termCSS: 'x-screen a { color: #ffdc80; }',

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: '12px 14px',

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#2a2833',
      red: '#72654d',
      green: '#605b76',
      yellow: '#b8a066',
      blue: '#6B52F0',
      magenta: '#b6aaee',
      cyan: '#ffdc80',
      white: '#a09bb7',
      lightBlack: '#2e2f31',
      lightRed: '#72654d',
      lightGreen: '#605b76',
      lightYellow: '#b8a066',
      lightBlue: '#6B52F0',
      lightMagenta: '#b6aaee',
      lightCyan: '#ffdc80',
      lightWhite: '#a09bb7'
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: '',

    // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
    // by default ['--login'] will be used
    shellArgs: ['--login'],

    // for environment variables
    env: {},

    // set to false for no bell
    bell: 'SOUND',

    // if true, selected text will automatically be copied to the clipboard
    copyOnSelect: false

    // URL to custom bell
    // bellSoundURL: 'http://example.com/bell.mp3',

    // for advanced config flags please refer to https://hyperterm.org/#cfg
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    'hyperlinks'
  ],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
