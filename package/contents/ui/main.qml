import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation

    property string trackTitleText: "Загрузка..."
    property string trackArtistText: ""
    property string trackLyricsText: "Ожидание текста..."

    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file://__HOME__/.cache/spotify_widget.json?" + Math.random(), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        root.trackTitleText = data.title;
                        root.trackArtistText = data.artist;
                        root.trackLyricsText = data.lyrics;
                    } catch(e) {}
                }
            }
            xhr.send();
        }
    }

    fullRepresentation: Rectangle {
        implicitWidth: 380
        implicitHeight: 130
        color: Qt.rgba(0.07, 0.07, 0.07, 0.8)
        radius: 14
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            PlasmaComponents.Label {
                text: "♫ SPOTIFY LYRICS"
                font.bold: true
                font.pixelSize: 11
                color: "#1DB954"
            }

            PlasmaComponents.Label {
                text: root.trackTitleText
                font.bold: true
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: root.trackArtistText
                font.pixelSize: 12
                color: "#B3B3B3"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            PlasmaComponents.Label {
                text: root.trackLyricsText
                font.pixelSize: 12
                font.bold: true
                color: "#FFFFFF"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
