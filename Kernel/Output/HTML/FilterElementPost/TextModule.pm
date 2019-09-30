# --
# Copyright (C) 2019–present Efflux GmbH, https://efflux.de/
# Part of the TextModule package.
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::FilterElementPost::TextModule;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
  my ($Type, %Param) = @_;

  my $Self = {};
  bless($Self, $Type);

  return $Self;
}

sub Run {
  my ($Self, %Param) = @_;

  my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
  my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
  my $TextModuleObject = $Kernel::OM->Get('Kernel::System::TextModule');

  my $TextModuleList = $TextModuleObject->GetList();

  return 1 if !@$TextModuleList;  # No text module found.

  $LayoutObject->AddJSData(
    Key   => 'TextModuleList',
    Value => $TextModuleList,
  );

  my %Translate = (
    TextModules => $LanguageObject->Translate('Text modules')
  );

  $Param{HTMLTop} = '<div id="TextModuleSidebar" class="WidgetSimple">';
  $Param{HTMLBottom} = '';

  # Addition HTML for pop-ups without a sidebar.
  if ($Param{TemplateFile} eq 'AgentTicketCompose' || $Param{TemplateFile} eq 'AgentTicketEmailOutbound' || $Param{TemplateFile} eq 'AgentTicketForward') {
    $Param{HTMLTop} = '<div class="SidebarColumn" id="TextModuleSidebar"><div class="WidgetSimple">';
    $Param{HTMLBottom} = '</div>';
  }

  my $HTML = "
    <div style='display: none;'>
      $Param{HTMLTop}
          <div class='Header'>
            <h2>$Translate{TextModules}</h2>
          </div>
          <div id='TextModuleContent' class='Content'>
            <div id='TextModuleTree' class='jstree-InputField jstree-InputField-Tree'></div>
          </div>
        $Param{HTMLBottom}
      </div>
    </div>
  ";

  ${$Param{Data}} .= $HTML;
  return 1;
}

1;
