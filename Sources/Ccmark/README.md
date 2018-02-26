## Instructions to update cmark

* Git clone https://github.com/commonmark/cmark.git
* cd cmark/src
* Copy all files except the ones ending .in into Kitura-Markdown/sources/Ccmark
* Replace any existing file and ensure include folder remains

Back in Ccmark:
```
brew install cmake
mkdir build
cd build
cmake ..
```
* open src
* copy any .h files into Kitura-Markdown/sources/Ccmark

* open cmark.h and replace angled brackets for cmark_export.h and cmark_version.h with double quotes ("")

* delete the main.c file
