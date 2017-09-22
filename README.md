# XLIFFMergeTool

# xliff-mergetool

```
Usage: xliff-mergetool [options]
  -d, --dev-lang:
      Path to the (auto-generated) Development Language XLIFF File
  -m, --merge-from:
      Path to the (partially) translated XLIFF File
  -h, --help:
      Prints a help message.
  -o, --operation:
      Merge operation: mergeExistingTranslations | mergeTargetIntoSource | info
```

## Build

```
swift build -c release
```

## Run

```
./.build/x86_64-apple-macosx10.10/release/xliff-mergetool
```

## Test

```
xcodebuild -scheme XLIFFMergeTool-Package  test
```

## Develop

Open Project in Xcode

```
open XLIFFMergeTool.xcodeproj/
```
