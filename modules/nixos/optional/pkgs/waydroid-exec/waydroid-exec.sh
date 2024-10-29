#!/usr/bin/env bash

# cage -- bash -c "waydroid app launch ${1}"
# cage -- bash -c "waydroid show-full-ui"
# cage -- bash -c "wlr-randr --output X11-1 --custom-mode 1280x800@60Hz ; waydroid app launch ${1}"
# cage -- bash -c "wlr-randr --output X11-1 --custom-mode 1280x800@60Hz ; waydroid show-full-ui"

if [ -z "\$1" ]
	then
		cage -- bash -c 'wlr-randr --output X11-1 --transform $TRANSFORM --custom-mode 1280x800@60Hz ;	\
			waydroid session start $@ & \
			sleep 5 ;\
			waydroid prop set persist.waydroid.height $HEIGHT ;\
			waydroid prop set persist.waydroid.width $WIDTH ;\
			waydroid session stop ;\
			
			waydroid session start $@ & \
			sleep 15 ; \

			sudo fix-controllers ;\
			waydroid show-full-ui $@ & '
	else
		cage -- env PACKAGE="\$1" bash -c 'wlr-randr --output X11-1 --custom-mode 1280x800@60Hz ; \\
			waydroid session start \$@ & \\

			sleep 15 ; \\
			sudo fix-controller ; \\

			sleep 1 ; \\
			waydroid app launch \$PACKAGE & \\

   			sleep 1 ; \\
      			waydroid show-full-ui $@ &'
fi