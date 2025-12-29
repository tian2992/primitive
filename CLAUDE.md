# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Primitive is a Go application that reproduces images using geometric primitives (triangles, rectangles, ellipses, etc.). It uses hill climbing optimization to iteratively add shapes that minimize the root-mean-square error between the target and generated images.

## Build and Run Commands

```bash
# Install the package
go get -u github.com/fogleman/primitive

# Build locally
go build

# Run with required arguments
primitive -i input.png -o output.png -n 100

# Example with multiple options
primitive -i input.png -o output.svg -o output.png -n 200 -m 1 -v
```

Key CLI flags:
- `-i`: input image path (use `-` for stdin)
- `-o`: output path (can specify multiple; use `-` for stdout with SVG)
- `-n`: number of shapes to generate
- `-m`: shape mode (0=combo, 1=triangle, 2=rect, 3=ellipse, 4=circle, 5=rotatedrect, 6=beziers, 7=rotatedellipse, 8=polygon)
- `-j`: number of parallel workers (defaults to all cores)
- `-v`/`-vv`: verbose output

## Architecture

### Core Algorithm Flow

1. **Model** (`primitive/model.go`): Central orchestrator that holds the target image, current state, and coordinates workers. The `Step()` method finds and adds the optimal next shape.

2. **Worker** (`primitive/worker.go`): Parallel workers that explore the shape space. Each worker generates random shapes and performs hill climbing to find locally optimal solutions. Workers share the target image but have independent random states.

3. **Optimization** (`primitive/optimize.go`): Implements `HillClimb()` and `Anneal()` algorithms via the `Annealable` interface. Hill climbing is preferred for speed.

4. **State** (`primitive/state.go`): Wraps a shape with its worker context, implementing `Annealable` for optimization.

### Shape System

All shapes implement the `Shape` interface (`primitive/shape.go`):
```go
type Shape interface {
    Rasterize() []Scanline  // Convert to scanlines for scoring
    Copy() Shape
    Mutate()                // Random mutation for hill climbing
    Draw(dc *gg.Context, scale float64)
    SVG(attrs string) string
}
```

Shape implementations: `Triangle`, `Rectangle`, `Ellipse`, `Circle`, `RotatedRectangle`, `Quadratic` (bezier), `RotatedEllipse`, `Polygon`

### Scoring Pipeline

1. Shapes are rasterized to scanlines (`Scanline` structs with Y, X1, X2, Alpha)
2. `computeColor()` calculates optimal color for a shape based on affected pixels
3. `differencePartial()` computes score change efficiently using only affected scanlines
4. The model tracks cumulative score improvements

### Key Design Decisions

- **Scanline rasterization**: Shapes are converted to horizontal scanlines for efficient pixel-level operations without anti-aliasing overhead during scoring
- **Partial difference**: Only pixels covered by a new shape are re-evaluated, not the entire image
- **Optimal color computation**: Color is computed directly (not optimized) based on the difference between target and current pixels in the shape area
- **Worker parallelism**: Multiple workers explore shape space concurrently, each with its own random state
