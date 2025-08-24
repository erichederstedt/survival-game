# TODO

- setup.hxml: Should setup all libs via haxelib and all cli tools via npm
- png textures: Add support for loading and rendering png textures
- ktx2 textures: Add support for loading and rendering ktx2 textures
- assets.hxml: Should process all pngs into ktx2 files
- compile.hxml: Basically what the current build.hxml currently is
- build.hxml: Basically calls all other hxml files except for setup
- engine git submodule: Split engine into its own git repo
- reorganize .hxml files: Basically move all .hxml files except for setup into the engine repo then have setup.hxml copy over the ones from the engine repo into the root project directory
