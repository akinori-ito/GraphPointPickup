# GraphPointPickup

## Overview

This program helps a user who wants to pick up points in a graph printed in paper or saved as an image file.

## Requirement
Tcl/Tk (8.4 or later), Tklib (packages img::jpeg, img::png, img::gif and img::bmp are used)

## How to use
1. Start the program. 
2. Choose [File]-[Open] and select the image file of the graph.
3. If the image is too small or too large, adjust the size of the image using [Zoom in] and [Zoom out] buttons. You can also change the size of the image pane by changing the canvas width and height.
3. Push [Lower left] button, and the cursor lines turn blue.
4. Align the cursor lines to the lower left point of the graph and click.
5. Input the coordinate of the lower left point.
6. Push the [Upper right] button, and the cursor lines turn green.
7. Align the cursor lines to the upper right point of the graph and click.
8. Input the coordinate of the upper right point.
9. Align the cursor lines to any point in the graph and click. Then the value of the point appears in the "Picked points" area.
10. Use [File]-[Save] to save the data as a CSV file.

## Author
Akinori Ito (aito@fw.ipsj.or.jp)
