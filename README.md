# Bezier-Automatic-Smooth


__The main subject of the project is SmoothBezier struct.__

SmoothBezier struct automatically generating bezier control points for perfect smoothing (purple dots)
Points for initializer are ralative values from 0 to 1 inside bounds (height and width) for ease of size changing.
You don't need to update all coordinates if you want to change shape size, just set bounds!

#### Usage:

    SmoothBezier init (
              points: [[CGFloat]], // Array of points in simple format [ [x, y], [x, y], [x, y], [x, y] ... ]
              boundsWidth: CGFloat, // Full width of shape
              boundsHeight: CGFloat, // Full height of shape
              margin: CGFloat = 0, // Margin from bounds inside (makes real shape smaller)
              smoothinessRatio: CGFloat = 33 // Level of smoothiness. 0 will give you corners.
              )

#### Preview:

![Alt text](Bezier%20Automatic%20Smooth/Img/SmoothShapeExample.jpg?raw=true "Title")
