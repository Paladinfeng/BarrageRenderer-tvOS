# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

BarrageRenderer-tvOS is a fork of [unash/BarrageRenderer](https://github.com/unash/BarrageRenderer), an Objective-C barrage (danmaku/弹幕) rendering engine. This fork adds tvOS support (deployment target tvOS 10.0) while maintaining iOS compatibility (iOS 9.0+). Distributed as a CocoaPod (`BarrageRendererTV`, v2.1.1).

## Build & development

```bash
# Install dependencies and open the demo workspace
cd BarrageRendererDemo && pod install && open BarrageRendererDemo.xcworkspace
```

There is no test target. All validation is manual via the demo app. The podspec source covers all `.h`/`.m` files under `BarrageRenderer/` and its subdirectories.

## Architecture

The engine has four layers, all in `BarrageRenderer/`:

### 1. Public API (top-level headers)
`BarrageHeader.h` is the umbrella header. Clients import this single file to get `BarrageRenderer`, `BarrageLoader`, `BarrageDescriptor`, and the four built-in sprite types.

### 2. Engine core (`BarrageEngine/`)
- **`BarrageRenderer`** — Main entry point. Owns and coordinates the clock, dispatcher, canvas, and sprite factory. Exposes `start`/`pause`/`stop` lifecycle, `receive:` to add a sprite, `load:` for batch loading with pre-set delays. Supports speed control, smoothness, canvas margins, z-index ordering, and a delegate for external time synchronization (for video-bound danmaku with seeking). `redisplay` enables replay when time moves backward.
- **`BarrageClock`** — Internal time engine. Extracts wall-clock time from CADisplayLink and applies `speed` multiplier to produce logical time.
- **`BarrageDispatcher`** — Schedules sprite activation. Receives sprites from the renderer and activates them when their `delay` matches the current logical time. Supports dead-sprite caching for redisplay and smoothness for burst damping.
- **`BarrageCanvas`** — The UIView that hosts all sprite views. Handles hit-testing (`masked` flag controls event interception). Applies `margin` insets to restrict the rendering area.
- **`BarrageSpriteFactory`** — Creates `BarrageSprite` instances from `BarrageDescriptor` objects using `NSClassFromString`.
- **`BarrageDescriptor`** — Data object carrying sprite configuration: `spriteName` (class name string), `params` (NSMutableDictionary of properties), and `identifier`. Supports `NSCopying` and click-action blocks.

### 3. Sprite hierarchy (`BarrageSprite/`)
- **`BarrageSprite`** (base) — Manages delay, position, validity lifecycle, and an associated `UIView<BarrageViewProtocol>`. Subclasses override `originInBounds:withSprites:` (initial placement), `rectWithTime:` (current rect), and `validWithTime:` (still active?).
- **`BarrageWalkSprite`** — Scrolling sprites (4 directions: R→L, L→R, T→B, B→T). Has `speed`, `direction`, `side` (left/right bias), `avoidCollision`, and `trackNumber`. Concrete text/image variants: `BarrageWalkTextSprite`, `BarrageWalkImageSprite`.
- **`BarrageFloatSprite`** — Stationary sprites that float for a `duration` (2 directions: T→B, B→T). Supports `fadeInTime`/`fadeOutTime` for opacity transitions, plus `side` for horizontal alignment. Concrete variants: `BarrageFloatTextSprite`, `BarrageFloatImageSprite`.

### 4. View reuse & protocols (`BarrageSprite/`)
- **`BarrageViewProtocol`** — Required methods: `prepareForReuse`, `configureWithParams:`. Optional: `updateWithTime:`. UIKit categories (`UIView+BarrageView`, `UILabel+BarrageView`, `UIImageView+BarrageView`) implement this protocol.
- **`BarrageViewPool`** — Object pool for recycling views to reduce allocation overhead.
- **`BarrageSpriteQueue`** — Ordered sprite queue used by the dispatcher for managing pending sprites.

### 5. Persistence (`BarrageLoader/`)
- **`BarrageLoader`** — Reads/writes descriptor arrays to files (plist-based). Also supports the "damaku" XML-like format.

## Key patterns

- **Adding a barrage**: Create a `BarrageDescriptor`, set `spriteName` (e.g., `BarrageWalkTextSprite`), configure `params` (text, color, speed, etc.), call `[renderer receive:descriptor]`.
- **Custom sprite views**: Set `descriptor.params[@"viewClassName"]` to a class name. That class must conform to `BarrageViewProtocol`. Use `descriptor.params[@"clickAction"]` for tap handling.
- **Video-bound danmaku**: Set `renderer.delegate`, implement `timeForBarrageRenderer:` to return current playback time, use `load:` with pre-timed descriptors (each has `delay` = video timestamp).
- **Collision avoidance**: `avoidCollision` property on walk/float sprites tries to place without overlap but may drop sprites when capacity is full. `trackNumber` controls maximum parallel tracks.
- **Smoothness**: `renderer.smoothness` (0–1) spreads out simultaneous sprites across frames to avoid burst-induced frame drops. High values may cause sprite loss under heavy load.

## Demo app

`BarrageRendererDemo/` uses CocoaPods with the local pod (`:path => '../'`). Key scenes:
- `CommonBarrageController` — Basic start/stop/pause, adding text/image sprites, speed control, canvas margins.
- `AdvancedBarrageController` — Video-bound danmaku with time synchronization, redisplay, and a custom mixed image-text sprite (`BarrageWalkImageTextSprite`).
- `AvatarBarrageView` / `FlowerBarrageSprite` — Examples of custom views and custom sprites.
