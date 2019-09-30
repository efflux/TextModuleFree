# --
# Copyright (C) 2019–present Efflux GmbH, https://efflux.de/
# Part of the TextModule package.
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TextModule;

use strict;
use warnings;
use utf8;

sub Data {
  my $Self = shift;

  $Self->{Translation}->{'Text Modules'} = 'Textbausteine';
  $Self->{Translation}->{'Text modules'} = 'Textbausteine';
  $Self->{Translation}->{'Create and manage text modules.'} = 'Textbausteine erzeugen und verwalten.';
  $Self->{Translation}->{'Manage Text Modules'} = 'Textbausteine-Verwaltung';
  $Self->{Translation}->{'Add Text Module'} = 'Textbaustein hinzufügen';
  $Self->{Translation}->{'Filter for Text Modules'} = 'Filter für Textbausteine';
  $Self->{Translation}->{'Edit Text Module'} = 'Textbaustein bearbeiten';
  $Self->{Translation}->{'Delete this text module'} = 'Diesen Textbaustein entfernen';
  $Self->{Translation}->{'Do you really want to delete this text module?'} = 'Wollen Sie diesen Textbaustein wirklich löschen?';
  $Self->{Translation}->{'Deleting text module ...'} = 'Textbaustein wird entfernt ...';
  $Self->{Translation}->{'Text module was deleted successfully.'} = 'Textbaustein erfolgreich entfernt.';
  $Self->{Translation}->{'There was an error deleting the text module. Please check the logs for more information.'} = 'Es ist ein Fehler beim Entfernen des Textbausteins aufgetreten. Bitte prüfen Sie die Protokolle für mehr Informationen.';
  $Self->{Translation}->{'A text module with this name already exists!'} = 'Ein Textbaustein mit diesem Namen ist bereits vorhanden!';
  $Self->{Translation}->{'Text module added.'} = 'Textbaustein hinzugefügt.';
  $Self->{Translation}->{'Text modules are response templates that are used frequently. In contrast to normal templates, text modules can be combined and used on all pages in which customer contact can take place.'} = 'Textbausteine sind Antwortvorlage, die häufig verwendet werden. Im Gegensatz zu normalen Vorlagen sind Textbausteine kombinierbar und auf allen Seiten nutzbar, in denen Kundenkontakt stattfinden kann.';
  $Self->{Translation}->{'The Pro version allows to filter text modules by pages, create categories, and other useful functions.'} = 'Die Pro-Version ermöglicht das Filtern von Textbausteinen nach Seiten, das Erstellen von Kategorien und weitere nützliche Funktionen.';
}

1;
