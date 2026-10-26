if [ "$CONFIGURATION" == "Debug-eflux" ] || [ "$CONFIGURATION" == "Release-eflux" ]; then
  cp Runner/eflux/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-elexon" ] || [ "$CONFIGURATION" == "Release-elexon" ]; then
  cp Runner/elexon/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-opcharge" ] || [ "$CONFIGURATION" == "Release-opcharge" ]; then
  cp Runner/opcharge/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-friwigo" ] || [ "$CONFIGURATION" == "Release-friwigo" ]; then
  cp Runner/friwigo/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-ezdrive" ] || [ "$CONFIGURATION" == "Release-ezdrive" ]; then
  cp Runner/ezdrive/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-nxt50five" ] || [ "$CONFIGURATION" == "Release-nxt50five" ]; then
  cp Runner/nxt50five/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-ezdriveplus" ] || [ "$CONFIGURATION" == "Release-ezdriveplus" ]; then
  cp Runner/ezdriveplus/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-vcityreunion" ] || [ "$CONFIGURATION" == "Release-vcityreunion" ]; then
  cp Runner/vcityreunion/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-nxtmobility" ] || [ "$CONFIGURATION" == "Release-nxtmobility" ]; then
  cp Runner/nxtmobility/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-mycomoly" ] || [ "$CONFIGURATION" == "Release-mycomoly" ]; then
  cp Runner/mycomoly/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-maesev" ] || [ "$CONFIGURATION" == "Release-maesev" ]; then
  cp Runner/maesev/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-kiachargenl" ] || [ "$CONFIGURATION" == "Release-kiachargenl" ]; then
  cp Runner/kiachargenl/GoogleService-Info.plist Runner/GoogleService-Info.plist
fi

