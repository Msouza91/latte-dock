/*
*  Copyright 2016  Smith AR <audoban@openmailbox.org>
*                  Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of Latte-Dock
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.latte 0.2 as Latte
import org.kde.latte.components 1.0 as LatteComponents

import "../code/ColorizerTools.js" as ColorizerTools

Item{
    id: indicatorRoot
    readonly property Item options: parent.manager

    readonly property real factor: 0.08
    readonly property int size: factor * options.currentIconSize
    readonly property int extraMaskThickness: reversedEnabled && glowEnabled ? 1.7 * (factor * options.maxIconSize) : 0

    property real textColorBrightness: ColorizerTools.colorBrightness(theme.textColor)

    property color isActiveColor: theme.buttonFocusColor
    property color minimizedColor: {
        if (multiColorEnabled) {
            return (textColorBrightness > 127.5 ? Qt.darker(theme.textColor, 1.7) : Qt.lighter(theme.textColor, 7));
        }

        return isActiveColor;
    }
    property color notActiveColor: options.isMinimized ? minimizedColor : isActiveColor

    //! Common Options
    readonly property bool reversedEnabled: options && options.common && options.common.hasOwnProperty("reversedEnabled") ?
                                                options.common.reversedEnabled : false

    //! Explicit Options
    readonly property bool explicitOptionsEnabled: options.explicit
                                                   && options.explicit.hasOwnProperty("styleName")
                                                   && options.explicit.styleName === "Latte"

    readonly property bool dotsOnActive: explicitOptionsEnabled ? options.explicit.dotsOnActive : true
    readonly property bool multiColorEnabled: explicitOptionsEnabled ? options.explicit.multiColorEnabled : false
    readonly property int activeIndicatorType: explicitOptionsEnabled ? options.explicit.activeIndicatorType : Latte.Types.LineIndicator
    //!glow options
    readonly property bool glowEnabled: explicitOptionsEnabled ? options.explicit.glowEnabled : true
    readonly property bool glow3D: explicitOptionsEnabled ? options.explicit.glow3D : false
    readonly property int glowOption: explicitOptionsEnabled ? options.explicit.glowOption : Latte.Types.GlowAll
    readonly property real glowOpacity: explicitOptionsEnabled ? options.explicit.glowOpacity : 0.35

    /*Rectangle{
        anchors.fill: parent
        border.width: 1
        border.color: "yellow"
        color: "transparent"
        opacity:0.6
    }*/

    Item{
        id: mainIndicatorElement

        width: flowItem.width
        height: flowItem.height

        Flow{
            id: flowItem
            flow: plasmoid.formFactor === PlasmaCore.Types.Vertical ? Flow.TopToBottom : Flow.LeftToRight

            LatteComponents.GlowPoint{
                id:firstPoint
                opacity: {
                    if (options.isTask) {
                        return options.isLauncher || (options.inRemoving && !activeAndReverseAnimation.running) ? 0 : 1
                    }

                    if (options.isApplet) {
                        return (options.isActive || activeAndReverseAnimation.running) ? 1 : 0
                    }
                }

                basicColor: options.isActive || (options.isGroup && options.hasShown) ? indicatorRoot.isActiveColor : indicatorRoot.notActiveColor

                size: indicatorRoot.size
                glow3D: glow3D
                animation: Math.max(1.65*3*units.longDuration,options.durationTime*3*units.longDuration)
                location: plasmoid.location
                glowOpacity: indicatorRoot.glowOpacity
                contrastColor: options.shadowColor
                attentionColor: theme.negativeTextColor

                roundCorners: true
                showAttention: options.inAttention
                showGlow: {
                    if (glowEnabled && (glowOption === Latte.Types.GlowAll || showAttention ))
                        return true;
                    else if (glowEnabled && glowOption === Latte.Types.GlowOnlyOnActive && options.hasActive)
                        return true;
                    else
                        return false;
                }
                showBorder: glowEnabled && glow3D

                property int stateWidth: options.isGroup ? indicatorRoot.width - secondPoint.width : indicatorRoot.width - spacer.width
                property int stateHeight: options.isGroup ? indicatorRoot.height - secondPoint.height : indicatorRoot.width - spacer.height

                property int animationTime: options.durationTime* (0.7*units.longDuration)

                property bool isActive: options.hasActive || options.isActive

                property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

                property real scaleFactor: options.scaleFactor

                function updateInitialSizes(){
                    if(indicatorRoot){
                        if(vertical)
                            width = indicatorRoot.size;
                        else
                            height = indicatorRoot.size;

                        if(vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator)
                            height = stateHeight;
                        else
                            height = indicatorRoot.size;

                        if(!vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator)
                            width = stateWidth;
                        else
                            width = indicatorRoot.size;
                    }
                }


                onIsActiveChanged: {
                    if (activeIndicatorType === Latte.Types.LineIndicator)
                        activeAndReverseAnimation.start();
                }

                onScaleFactorChanged: {
                    if(!activeAndReverseAnimation.running && !vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator){
                        width = stateWidth;
                    }
                    else if (!activeAndReverseAnimation.running && vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator){
                        height = stateHeight;
                    }
                }

                onStateWidthChanged:{
                    if(!activeAndReverseAnimation.running && !vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator)
                        width = stateWidth;
                }

                onStateHeightChanged:{
                    if(!activeAndReverseAnimation.running && vertical && isActive && activeIndicatorType === Latte.Types.LineIndicator)
                        height = stateHeight;
                }

                onVerticalChanged: updateInitialSizes();

                Component.onCompleted: {
                    updateInitialSizes();

                    if (options) {
                        options.onCurrentIconSizeChanged.connect(updateInitialSizes);
                    }
                }

                Component.onDestruction: {
                    if (options) {
                        options.onCurrentIconSizeChanged.disconnect(updateInitialSizes);
                    }
                }

                NumberAnimation{
                    id: activeAndReverseAnimation
                    target: firstPoint
                    property: plasmoid.formFactor === PlasmaCore.Types.Vertical ? "height" : "width"
                    to: options.hasActive && activeIndicatorType === Latte.Types.LineIndicator
                        ? (plasmoid.formFactor === PlasmaCore.Types.Vertical ? firstPoint.stateHeight : firstPoint.stateWidth) : indicatorRoot.size
                    duration: firstPoint.animationTime
                    easing.type: Easing.InQuad

                    onStopped: firstPoint.updateInitialSizes()
                }
            }

            Item{
                id:spacer
                width: secondPoint.visible ? 0.5*indicatorRoot.size : 0
                height: secondPoint.visible ? 0.5*indicatorRoot.size : 0
            }

            LatteComponents.GlowPoint{
                id:secondPoint
                width: visible ? indicatorRoot.size : 0
                height: width

                size: indicatorRoot.size
                glow3D: glow3D
                animation: Math.max(1.65*3*units.longDuration,options.durationTime*3*units.longDuration)
                location: plasmoid.location
                glowOpacity: indicatorRoot.glowOpacity
                contrastColor: options.shadowColor
                showBorder: glowEnabled && glow3D

                basicColor: state2Color
                roundCorners: true
                showGlow: glowEnabled  && glowOption === Latte.Types.GlowAll
                visible:  ( options.isGroup && ((dotsOnActive && activeIndicatorType === Latte.Types.LineIndicator)
                                                || activeIndicatorType === Latte.Types.DotIndicator
                                                || !options.hasActive) )? true: false

                //when there is no active window
                property color state1Color: options.hasShown ? indicatorRoot.isActiveColor : indicatorRoot.minimizedColor
                //when there is active window
                property color state2Color: options.hasMinimized ? indicatorRoot.minimizedColor : indicatorRoot.isActiveColor
            }
        }

        states: [
            State {
                name: "left"
                when: ((plasmoid.location === PlasmaCore.Types.LeftEdge && !reversedEnabled) ||
                       (plasmoid.location === PlasmaCore.Types.RightEdge && reversedEnabled))

                AnchorChanges {
                    target: mainIndicatorElement
                    anchors{ verticalCenter:parent.verticalCenter; horizontalCenter:undefined;
                        top:undefined; bottom:undefined; left:parent.left; right:undefined;}
                }
            },
            State {
                name: "bottom"
                when: (plasmoid.location === PlasmaCore.Types.Floating ||
                       (plasmoid.location === PlasmaCore.Types.BottomEdge && !reversedEnabled) ||
                       (plasmoid.location === PlasmaCore.Types.TopEdge && reversedEnabled))

                AnchorChanges {
                    target: mainIndicatorElement
                    anchors{ verticalCenter:undefined; horizontalCenter:parent.horizontalCenter;
                        top:undefined; bottom:parent.bottom; left:undefined; right:undefined;}
                }
            },
            State {
                name: "top"
                when: ((plasmoid.location === PlasmaCore.Types.TopEdge && !reversedEnabled) ||
                       (plasmoid.location === PlasmaCore.Types.BottomEdge && reversedEnabled))

                AnchorChanges {
                    target: mainIndicatorElement
                    anchors{ verticalCenter:undefined; horizontalCenter:parent.horizontalCenter;
                        top:parent.top; bottom:undefined; left:undefined; right:undefined;}
                }
            },
            State {
                name: "right"
                when: ((plasmoid.location === PlasmaCore.Types.RightEdge && !reversedEnabled) ||
                       (plasmoid.location === PlasmaCore.Types.LeftEdge && reversedEnabled))

                AnchorChanges {
                    target: mainIndicatorElement
                    anchors{ verticalCenter:parent.verticalCenter; horizontalCenter:undefined;
                        top:undefined; bottom:undefined; left:undefined; right:parent.right;}
                }
            }
        ]
    }
}// number of windows indicator
