# better_file_md5_plugin

Calculate File Md5 for Flutter.

## Install Started

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  better_file_md5_plugin: ^0.0.1
```

2. Install it

```bash
$ flutter packages get
```

## Normal usage

```dart
  final md5 = await BetterFileMd5.md5(file.path);
  if (md5 != null)
    hexMd5 = hex.encode(base64Decode(md5));
```

## Feature
- [x] file md5
