# --
# Copyright (C) 2019–present Efflux GmbH, https://efflux.de/
# Part of the TextModule package.
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Modules::AdminTextModule;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
  my ($Type, %Param) = @_;

  my $Self = {%Param};
  bless($Self, $Type);

  return $Self;
}

sub Run {
  my ($Self, %Param) = @_;

  my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
  my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
  my $TextModuleObject = $Kernel::OM->Get('Kernel::System::TextModule');

  my $StdAttachmentObject = $Kernel::OM->Get('Kernel::System::StdAttachment');

  if ($Self->{Subaction} eq 'Change') {
    my $ID = $ParamObject->GetParam(Param => 'ID') || '';
    my $TextModule = $TextModuleObject->GetTextModule(ID => $ID);

    $Self->_Edit(
      Action => 'Change',
      %$TextModule
    );

    return $LayoutObject->Header() .
           $LayoutObject->NavigationBar() . 
           $LayoutObject->Output(
             TemplateFile => 'AdminTextModule',
             Data         => \%Param,
           ) . $LayoutObject->Footer();
  } elsif ($Self->{Subaction} eq 'ChangeAction') {
    $LayoutObject->ChallengeTokenCheck();

    my (%GetParam, %Errors);

    for my $Parameter (qw(ID Name Text Comment ValidID ContinueAfterSave)) {
      $GetParam{$Parameter} = $ParamObject->GetParam(Param => $Parameter) || '';
    }

    for my $Mandatory (qw(Name ValidID)) {
      if (!$GetParam{$Mandatory}) {
        $Errors{$Mandatory . 'Invalid'} = 'ServerError';
      }
    }

    my $NameExists = $TextModuleObject->CheckNameExists(
      ID => $GetParam{ID},
      Name => $GetParam{Name}
    );
    
    if ($NameExists) {
      $Errors{NameExists} = 1;
      $Errors{'NameInvalid'} = 'ServerError';
    }

    # Error handling
    if (%Errors) {
      $Self->_Edit(
        Action => 'Change',
        Errors => \%Errors,
        %GetParam
      );

      return $LayoutObject->Header() .
             $LayoutObject->NavigationBar() .
             $LayoutObject->Notify(Priority => 'Error') .
             $LayoutObject->Output(
               TemplateFile => 'AdminTextModule',
               Data         => \%Param
             ) . $LayoutObject->Footer();
    } elsif (!$GetParam{ID}) {
      return $LayoutObject->ErrorScreen(
        Message => Translatable('No such ID!'),
        Comment => Translatable("The text module ID you've tryed to change does not exist. Please check your URL."),
      );
    }

    $TextModuleObject->Update(
      ID => $GetParam{ID},
      Name => $GetParam{Name},
      Text => $GetParam{Text},
      Comment => $GetParam{Comment},
      ValidID => $GetParam{ValidID}
    );

    if ($GetParam{ContinueAfterSave} eq '1') {
      return $LayoutObject->Redirect(OP => "Action=$Self->{Action};Subaction=Change;ID=$GetParam{ID}");
    } else {
      return $LayoutObject->Redirect(OP => "Action=$Self->{Action}");
    }
  } elsif ($Self->{Subaction} eq 'Add') {
    $Self->_Edit(Action => 'Add');

    return $LayoutObject->Header() .
           $LayoutObject->NavigationBar() . 
           $LayoutObject->Output(
             TemplateFile => 'AdminTextModule',
             Data         => \%Param,
           ) . $LayoutObject->Footer();
  } elsif ($Self->{Subaction} eq 'AddAction') {
    $LayoutObject->ChallengeTokenCheck();

    my (%GetParam, %Errors);

    for my $Parameter (qw(ID Name Text Comment ValidID)) {
      $GetParam{$Parameter} = $ParamObject->GetParam(Param => $Parameter) || '';
    }

    for my $Mandatory (qw(Name ValidID)) {
      if (!$GetParam{$Mandatory}) {
        $Errors{$Mandatory . 'Invalid'} = 'ServerError';
      }
    }

    my $NameExists = $TextModuleObject->CheckNameExists(Name => $GetParam{Name});
    
    if ($NameExists) {
      $Errors{NameExists} = 1;
      $Errors{'NameInvalid'} = 'ServerError';
    }
    
    # Error handling
    if (%Errors) {
      $Self->_Edit(
        Action => 'Add',
        Errors => \%Errors,
        %GetParam
      );

      return $LayoutObject->Header() .
             $LayoutObject->NavigationBar() .
             $LayoutObject->Notify(Priority => 'Error') .
             $LayoutObject->Output(
               TemplateFile => 'AdminTextModule',
               Data         => \%Param
             ) . $LayoutObject->Footer();
    }

    $TextModuleObject->Insert(
      Name => $GetParam{Name},
      Text => $GetParam{Text},
      Comment => $GetParam{Comment},
      ValidID => $GetParam{ValidID}
    );

    $Self->_Overview();

    return $LayoutObject->Header() .
           $LayoutObject->NavigationBar() .
           $LayoutObject->Notify(Info => Translatable('Text module added.')) .
           $LayoutObject->Output(
             TemplateFile => 'AdminTextModule',
             Data         => \%Param
           ) . $LayoutObject->Footer();
  } elsif ( $Self->{Subaction} eq 'Delete' ) {
    $LayoutObject->ChallengeTokenCheck();

    my $ID = $ParamObject->GetParam(Param => 'ID');
    my $Deleted = $TextModuleObject->Delete(ID => $ID);

    return $LayoutObject->Attachment(
      ContentType => 'text/html',
      Content     => $Deleted ? $ID : 0,
      Type        => 'inline',
      NoCache     => 1
    );
  } else {  # Default overview.
    $Self->_Overview();

    return $LayoutObject->Header() .
           $LayoutObject->NavigationBar() .
           $LayoutObject->Output(
             TemplateFile => 'AdminTextModule',
             Data         => \%Param
           ) . $LayoutObject->Footer();
  }
}

sub _Edit {
  my ($Self, %Param) = @_;

  my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
  my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

  $LayoutObject->Block(
    Name => 'Overview',
    Data => \%Param
  );
  $LayoutObject->Block(Name => 'ActionList');
  $LayoutObject->Block(Name => 'ActionOverview');
  $LayoutObject->SetRichTextParameters(Data => \%Param);

  my %ValidList = $ValidObject->ValidList();
  my %ValidListReverse = reverse %ValidList;

  $Param{ValidOption} = $LayoutObject->BuildSelection(
    Data       => \%ValidList,
    Name       => 'ValidID',
    SelectedID => $Param{ValidID} || $ValidListReverse{valid},
    Class      => 'Modernize Validate_Required ' . ($Param{Errors}->{'ValidIDInvalid'} || '')
  );

  if ($Param{Action} eq 'Add') {  # ?
    $Param{ValidateContent} = "Validate_Required";
  }

  $LayoutObject->Block(
    Name => 'OverviewUpdate',
    Data => {
      %Param,
      %{$Param{Errors}}
    }
  );

  return 1;
}

sub _Overview {
  my ($Self, %Param) = @_;

  my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
  my $TextModuleObject = $Kernel::OM->Get('Kernel::System::TextModule');
  my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

  $LayoutObject->Block(
    Name => 'Overview',
    Data => \%Param
  );
  $LayoutObject->Block(Name => 'ActionList');
  $LayoutObject->Block(Name => 'ActionAdd');
  $LayoutObject->Block(Name => 'Filter');
  $LayoutObject->Block(
    Name => 'OverviewResult',
    Data => \%Param
  );

  my $TextModuleOverview = $TextModuleObject->GetOverview();

  if (@$TextModuleOverview) {
    my %ValidList = $ValidObject->ValidList();

    for my $TextModule (@$TextModuleOverview) {
      $TextModule->{Valid} = $ValidList{$TextModule->{ValidID}};

      $LayoutObject->Block(
        Name => 'OverviewResultRow',
        Data => $TextModule
      );
    }
  } else {
    $LayoutObject->Block(Name => 'NoDataFoundMsg');
  }

  return 1;
}

1;
