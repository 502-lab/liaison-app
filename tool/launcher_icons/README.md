# 앱 아이콘

`prod.svg`, `dev.svg`가 원본이다. `dev.svg`는 prod와 같은 모양에 DEV 띠를 얹은 것으로, 한 기기에 두 flavor를 같이 설치했을 때 구분하기 위한 것이다. 지금 그림은 디자인 확정 전 placeholder다.

## 다시 생성하기

시안이 나오면 두 SVG를 교체한 뒤 프로젝트 루트에서:

```bash
# 1. SVG → 1024px PNG (macOS 내장 qlmanage 사용)
qlmanage -t -s 1024 -o tool/launcher_icons tool/launcher_icons/prod.svg tool/launcher_icons/dev.svg
mv tool/launcher_icons/prod.svg.png tool/launcher_icons/prod.png
mv tool/launcher_icons/dev.svg.png tool/launcher_icons/dev.png

# 2. Android(mipmap-*)와 iOS(AppIcon-<flavor>.appiconset)에 flavor별로 배치
fvm dart run flutter_launcher_icons
```

설정은 루트의 `flutter_launcher_icons-dev.yaml`, `flutter_launcher_icons-prod.yaml`이다. 파일 이름의 flavor 접미사에 따라 Android는 `android/app/src/<flavor>/res/`, iOS는 `AppIcon-<flavor>.appiconset`에 쓴다.

디자이너가 PNG(1024×1024, 투명 없음)를 주면 SVG 단계를 건너뛰고 `prod.png`, `dev.png`를 바로 교체해도 된다.
