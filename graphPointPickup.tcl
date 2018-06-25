#
# Graph point pickup tool
#
# by Akinori Ito, 24 September 2009
#
package require img::gif
package require img::jpeg
package require img::bmp
package require img::png

set version 0.01

set orig_graph {}
set cur_scale 4
set cur_graph {}
set cur_graphitem {}

set cur_mode get_point
set phys_1 {0 600}
set phys_2 {600 0}

frame .menub -relief raised
pack .menub -fill both
menubutton .menub.file -text File
pack .menub.file -side left -anchor w
menu .menub.file.file  -tearoff 0
.menub.file configure -menu .menub.file.file 
.menub.file.file add cascade -label Open -command open_image
.menub.file.file add cascade -label Save -command save_data
.menub.file.file add cascade -label Exit -command {exit}

frame .f 
pack .f -side top -anchor n -fill both -expand yes

frame .f.l
frame .f.r -relief solid -borderwidth 3
pack .f.l -side left -anchor n
pack .f.r -side left -anchor n -fill both -expand yes

frame .f.l.pt
#pack .f.l.pt -side top
button .f.l.pt.l1 -text {Lower left} -command {get_pt1_mode}
entry .f.l.pt.x1 -width 6 
entry .f.l.pt.y1 -width 6 
label .f.l.pt.p1 -text {Unspecified}
button .f.l.pt.l2 -text {Upper right} -command {get_pt2_mode}
entry .f.l.pt.x2 -width 6 
entry .f.l.pt.y2 -width 6 
label .f.l.pt.p2 -text {Unspecified}
grid .f.l.pt.l1 -row 0 -column 0
grid .f.l.pt.x1 -row 0 -column 1
grid .f.l.pt.y1 -row 0 -column 2
grid .f.l.pt.p1 -row 0 -column 3
grid .f.l.pt.l2 -row 1 -column 0
grid .f.l.pt.x2 -row 1 -column 1
grid .f.l.pt.y2 -row 1 -column 2
grid .f.l.pt.p2 -row 1 -column 3
.f.l.pt.x1 insert end 0.0
.f.l.pt.y1 insert end 0.0
.f.l.pt.x2 insert end 1.0
.f.l.pt.y2 insert end 1.0

label .f.l.lab1 -text {Picked points}
text .f.l.text -width 30 -height 10 -yscrollcommand ".f.l.scr set"
scrollbar .f.l.scr -orient vertical -command ".f.l.text yview"
frame .f.l.b
frame .f.l.b2
frame .f.l.b3

grid .f.l.pt   -row 0 -column 0
grid .f.l.lab1 -row 1 -column 0 
grid .f.l.text -row 2 -column 0
grid .f.l.scr  -row 2 -column 1 -sticky ns
grid .f.l.b    -row 3 -column 0 -columnspan 2
grid .f.l.b2   -row 4 -column 0 -columnspan 2
grid .f.l.b3   -row 5 -column 0 -columnspan 2

button .f.l.b.clear -text CLEAR -command {.f.l.text delete 1.0 end}
button .f.l.b.del -text "Erase last" -command {.f.l.text delete [.f.l.text index "end -2 lines"] "end -1 chars"}
button .f.l.b.half -text "Zoom in" -command zoomin
button .f.l.b.dbl -text "Zoom out" -command zoomout
pack .f.l.b.clear .f.l.b.del .f.l.b.half .f.l.b.dbl -side left

checkbutton .f.l.b2.logx -variable logx
checkbutton .f.l.b2.logy -variable logy
label .f.l.b2.lx -text "X logscale"
label .f.l.b2.ly -text "Y logscale"
grid .f.l.b2.logx -row 0 -column 0
grid .f.l.b2.logy -row 1 -column 0
grid .f.l.b2.lx -row 0 -column 1
grid .f.l.b2.ly -row 1 -column 1

label .f.l.b3.l1 -text "Canvas width:"
entry .f.l.b3.canvaswidth -width 6 -textvariable canvaswidth
label .f.l.b3.l2 -text "Canvas height:"
entry .f.l.b3.canvasheight -width 6 -textvariable canvasheight
button .f.l.b3.change -text CHANGE -command canvasSizeChange
grid .f.l.b3.l1 -row 0 -column 0
grid .f.l.b3.canvaswidth -row 0 -column 1
grid .f.l.b3.l2 -row 1 -column 0
grid .f.l.b3.canvasheight -row 1 -column 1
grid .f.l.b3.change -row 2 -column 0
set canvaswidth 600
set canvasheight 600

scrollbar .f.r.vert -orient vertical -command ".f.r.graph yview"
scrollbar .f.r.horiz -orient horizontal -command ".f.r.graph xview"
canvas .f.r.graph -width 600 -height 600 -bg white -xscrollcommand ".f.r.horiz set" -yscrollcommand ".f.r.vert set"
grid .f.r.graph -row 0 -column 0 -sticky ns
grid .f.r.vert -row 0 -column 1 -sticky ns
grid .f.r.horiz -row 1 -column 0 -sticky ew

set horizLine [.f.r.graph create line 0 0 600 0 -fill red]
set vertLine [.f.r.graph create line 0 0 600 0 -fill red]

bind .f.r.graph <Motion> {
  .f.r.graph coord $horizLine 0 %y $canvaswidth %y
  .f.r.graph coord $vertLine %x 0 %x $canvasheight
  continue
}
bind .f.r.graph <ButtonPress> {button_proc %x %y}

proc button_proc {x y} { 
  global cur_mode
  $cur_mode $x $y
}

proc coord_conv {val p1 p2 r1 r2 rev logscale} {
  if {$p1 > $p2} {
    set q $p1
    set p1 $p2
    set p2 $q
  }
  set pdif [expr $p2-$p1]
  set ratio [expr 1.0*($val-$p1)/$pdif]
  if {$rev} {
    set ratio [expr 1.0-$ratio]
  }
  if {$logscale} {
    set r1 [expr log($r1)]
    set r2 [expr log($r2)]
    return [expr exp($r1+$ratio*($r2-$r1))]    
  } else {
    return [expr $r1+$ratio*($r2-$r1)]
  }
}

proc get_point {x y} {
  global phys_1 phys_2 logx logy
  set realx [coord_conv $x [lindex $phys_1 0] [lindex $phys_2 0] [.f.l.pt.x1 get] [.f.l.pt.x2 get] 0 $logx] 
  set realy [coord_conv $y [lindex $phys_1 1] [lindex $phys_2 1] [.f.l.pt.y1 get] [.f.l.pt.y2 get] 1 $logy] 

  .f.l.text insert end "$realx,$realy\n"
}
proc get_pt1 {x y} {
  global phys_1 horizLine vertLine cur_mode
  set phys_1 [list $x $y]
  .f.r.graph itemconfigure $horizLine -fill red
  .f.r.graph itemconfigure $vertLine -fill red
  set cur_mode get_point
  .f.l.pt.p1 configure -text [join $phys_1 ","]
}
proc get_pt2 {x y} {
  global phys_2 horizLine vertLine cur_mode
  set phys_2 [list $x $y]
  .f.r.graph itemconfigure $horizLine -fill red
  .f.r.graph itemconfigure $vertLine -fill red
  set cur_mode get_point
  .f.l.pt.p2 configure -text [join $phys_2 ","]
}

proc get_pt1_mode {} {
  global horizLine vertLine cur_mode
  .f.r.graph itemconfigure $horizLine -fill blue
  .f.r.graph itemconfigure $vertLine -fill blue
  set cur_mode get_pt1
}
proc get_pt2_mode {} {
  global horizLine vertLine cur_mode
  .f.r.graph itemconfigure $horizLine -fill green
  .f.r.graph itemconfigure $vertLine -fill green
  set cur_mode get_pt2
}

proc open_image {} {
  global cur_graph orig_graph cur_scale
  set file [tk_getOpenFile -filetypes {{"Image files" {.bmp .BMP .gif .GIF .jpg .JPG .jpeg .JPEG .png .PNG}}}]
  if {$file == ""} { return }
  if {$cur_graph != ""} {
     image delete $cur_graph
     image delete $orig_graph
  }
  set orig_graph [image create photo -file $file]
  set cur_graph [image create photo]
  $cur_graph copy $orig_graph
  set cur_scale 4
  update_image
}

proc update_image {} {
  global cur_graph cur_graphitem horizLine
  if {$cur_graphitem != ""} {
    .f.r.graph delete $cur_graphitem
  }
  set cur_graphitem [.f.r.graph create image 0 0 -image $cur_graph -anchor nw]
  .f.r.graph lower $cur_graphitem $horizLine
}

proc zoomin {} {
  zoom 1
}

proc zoomout {} {
  zoom -1
}

proc zoom {scale} {
  global cur_graph cur_scale orig_graph
  incr cur_scale $scale
  if {$cur_scale == 4} {
    $cur_graph copy $orig_graph
  } elseif {$cur_scale > 4} {
    if {$cur_scale == 8} {
      set cur_scale 7
    } else {
      set zoom [expr $cur_scale-3]
      $cur_graph copy $orig_graph -zoom $zoom $zoom
    }
  } else {
    if {$cur_scale == 0} {
      set cur_scale 1
    } else {
      set sub [expr 5-$cur_scale]
      $cur_graph copy $orig_graph -shrink -subsample $sub $sub
    }
  }
  update_image
}

proc save_data {} {
  set file [tk_getSaveFile -defaultextension .csv -filetypes {{{Text CSV} .csv} {{All files} *}}]
  if {$file eq ""} {
    return
  }
  set f [open $file w]
  puts $f [.f.l.text get 1.0 end]
  close $f
}

proc canvasSizeChange {} {
  global canvaswidth canvasheight phys_1 phys_2
  lset phys_1 1 $canvaswidth
  lset phys_2 0 $canvasheight
  .f.r.graph configure -width $canvaswidth -height $canvasheight
}
    
