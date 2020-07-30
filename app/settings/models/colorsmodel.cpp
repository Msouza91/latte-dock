/*
 * Copyright 2020  Michail Vourlakos <mvourlakos@gmail.com>
 *
 * This file is part of Latte-Dock
 *
 * Latte-Dock is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * Latte-Dock is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "colorsmodel.h"

// local
#include "../../layout/abstractlayout.h"

// KDE
#include <KLocalizedString>

namespace Latte {
namespace Settings {
namespace Model {

Colors::Colors(QObject *parent, Latte::Corona *corona)
    : QAbstractTableModel(parent),
      m_corona(corona)
{
    //!find the available colors
    m_colorsPath = m_corona->kPackage().path() + "../../plasmoids/org.kde.latte.containment/contents/icons/";

    init();
}

Colors::~Colors()
{
}

void Colors::init()
{
    QString id;
    id = "blue"; add(id, i18n("Blue"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "brown"; add(id, i18n("Brown"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "darkgrey"; add(id, i18n("Dark Grey"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "gold"; add(id, i18n("Gold"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "green"; add(id, i18n("Green"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "lightskyblue"; add(id, i18n("Light Sky Blue"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "orange"; add(id, i18n("Orange"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "pink"; add(id, i18n("Pink"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "purple"; add(id, i18n("Purple"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "red"; add(id, i18n("Red"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
    id = "wheat"; add(id, i18n("Wheat"), colorPath(id), Layout::AbstractLayout::defaultTextColor(id));
}

QString Colors::colorPath(const QString &color)
{
    return QString(m_colorsPath + color + "print.jpg");
}

void Colors::add(const QString &newid, const QString &newname, const QString &newpath, const QString &newtextcolor)
{
    Data::Color color;
    color.setData(newid, newname, newpath, newtextcolor);
    m_colorsTable << color;
}

int Colors::rowCount() const
{
    return m_colorsTable.count();
}

int Colors::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return m_colorsTable.count();
}

int Colors::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return TEXTCOLORROLE+1;
}

int Colors::row(const QString &id)
{
    for (int i=0; i<m_colorsTable.count(); ++i){
        if (m_colorsTable[i].id == id) {
            return i;
        }
    }

    return -1;
}

QVariant Colors::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    int column = index.column();

    if (row >= rowCount()) {
        return QVariant{};
    }

    if (role == NAMEROLE || role == Qt::DisplayRole) {
        return m_colorsTable[row].name;
    } else if (role == IDROLE) {
            return m_colorsTable[row].id;
    } else if (role == PATHROLE) {
        return m_colorsTable[row].path;
    } else if (role == TEXTCOLORROLE) {
        return m_colorsTable[row].textColor;
    }

    return QVariant{};
}

}
}
}
