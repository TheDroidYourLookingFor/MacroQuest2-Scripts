|------------------------------------------------------------| 
|          MoveBot.Locations.inc 
| 
|      Last Modified by: TheDroidUrLookingFor 
|
|		Version:	1.0.1
|
|------------------------------------------------------------|
Sub Hatchery
/if (${Zone.Name.Equal[Hatchery Wing]}) {
/echo I am in ${Zone}!

| Location #1
/call Move -47.45 -31.34 2.52
/delay 5

| Location #2
/call Move 16.73 0.95 2.47
/delay 5

| Location #
/call Move 135.84 -136.95 -21.63
/delay 5

| Location #
/call Move 261.19 -261.55 -51.11
/delay 5

| Location #
/call Move 335.37 -160.68 -88.04
/delay 5

| Location #
/call Move 308.65 1.12 -131.68
/delay 5

| Location #
/call Move 616.46 -59.21 -22.97
/delay 5

| Location #
/call Move 667.64 -5.76 -22.97
/delay 5

| Location #
/call Move 615.77 48.92 -22.97
/delay 5

| Location #
/call Move 355.31 24.65 -131.75
/delay 5

| Location #
/call Move 335.54 159.69 -88.04
/delay 5

| Location #
/call Move 232.60 263.49 -55.28
/delay 5

| Location #
/call Move 137.11 136.96 -21.63
/delay 5

| Location #
/call Move 142.50 13.70 -30.41
/delay 5

| Location #
/call Move -29.48 38.97 2.41
/delay 5
}

/echo Finished running around to pull everything!
/end
/return

Sub WallOfSlaughter
/if (${Zone.Name.Equal[Wall of Slaughter]}) {
/echo I am in ${Zone}!
/call Move -1698.07 1980 108.32
/doortarget MAZEDOOR
/face door
/click leftmouse
}
/return

Sub MuramiteProvingGrounds
/if (${Zone.Name.Equal[Muramite Proving Grounds]}) {
/echo I am in ${Zone}!
/call Move -851.32 -2444.69 -306.85
/doortarget CT_CRYSTAL
/face door
/click leftmouse
}
/return

Sub RiftSeekers
/if (${Zone.Name.Equal[Riftseekers' Sanctum]}) {
/echo I am in ${Zone}!

| Ground Location #1
/call Move 708 40 -236
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #2
/call Move 479 -178 -236
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #3
/call Move -2 -443 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #4
/call Move -702 -405 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #5
/call Move -482 -180 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #6
/call Move -696 298 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #7
/call Move -472 783 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #8
/call Move -4 992 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Ground Location #9
/call Move 474 775 -235
/call SetAnchor
/delay 5
/call KillAllNear

| Return to Zone In
/call Move 0 97 -236
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #1
/call Move 1266 455 -535
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #2
/call Move 1421 1117 -553
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #3
/call Move 1090 1426 -553
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #4
/call Move 564 1559 -553
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #5
/call Move 97 1655 -595
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #6
/call Move -203 1211 -616
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #7
/call Move 564 1150 -593
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #8
/call Move 1041 1045 -535
/call SetAnchor
/delay 5
/call KillAllNear

| Basement Location #9
/call Move 495 573 -473
/call SetAnchor
/delay 5
/call KillAllNear

| Return to Zone In
/call Move 0 97 -236
/call SetAnchor
/delay 5
/call KillAllNear

| Move Upstairs
/call Move -764 614 2
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #1
/call Move -845 -197 -18
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #2
/call Move -1233 188 4
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #3
/call Move 1165 616 44
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #4
/call Move -1080 1116 44
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #5
/call Move -546 1212 64
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #6
/call Move -100 1328 64
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #7
/call Move 261 1728 163
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #8
/call Move 205 263 303
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #9
/call Move 620 214 303
/call SetAnchor
/delay 5
/call KillAllNear

| Upstairs Location #10
/call Move -227 233 303
/call SetAnchor
/delay 5
/call KillAllNear

| Return to Zone In
/call Move 0 97 -236
/call SetAnchor
/delay 5
/call KillAllNear
}
/return