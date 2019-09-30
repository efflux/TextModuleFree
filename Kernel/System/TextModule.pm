# --
# Copyright (C) 2019–present Efflux GmbH, https://efflux.de/
# Part of the TextModule package.
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::TextModule;

use strict;
use warnings;

our @ObjectDependencies = (
  'Kernel::System::DB'
);

=head1 TextModule
my $TextModuleObject = $Kernel::OM->Get('Kernel::System::TextModule');
=cut

sub new {
  my ($Type, %Param) = @_;

  my $Self = {};
  bless($Self, $Type);

  return $Self;
}

=head2 GetList()
Get a list that contains all text module information.

Example:
  my $List = $TextModuleObject->GetList();

Returns:
  $List = [
    {
      "icon":"fa fa-file-text-o",
      "text":"Name",
      "title":null,
      "data":{ 
         "text":"<p>HTML Text</p>"
      },
      "id":"text-module_1"
    },
    ...
  ]
=cut

sub GetList {
  my ($Self, %Param) = @_;

  my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

  my @List = ();
  $DBObject->Prepare(
    SQL => '
      SELECT id, name, text, comment
      FROM text_module
      WHERE valid_id = 1'
  );

  while (my @Row = $DBObject->FetchrowArray()) {
    my $Ref = {
      id => 'text-module_' . $Row[0],
      text => $Row[1],
      icon => 'fa fa-file-text-o',
      data => {
        text => $Row[2]
      },
      title => $Row[3]
    };

    push @List, $Ref; 
  }

  return \@List;
}

=head2 GetOverview()
Return an array ref with all text module information.

Example:
  my $TextModuleOverview = $TextModuleObject->GetOverview();

Returns:
  $TextModuleOverview = 
    [
      {
        'ID' => '1',
        'Name' => 'Name'
        'Comment' => 'My comment',
        'ValidID' => '1',
        'CreateTime' => '2019-09-11 19:00:00',
        'ChangeTime' => '2019-09-11 19:00:00',
      },
      ...
    ];

=cut

sub GetOverview {
  my ($Self, %Param) = @_;

  my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

  my @List = ();
  $DBObject->Prepare(
    SQL => '
      SELECT id, name, comment, valid_id, create_time, change_time
      FROM text_module'
  );

  while (my @Row = $DBObject->FetchrowArray()) {
    my %TextModule = (
      ID         => $Row[0],
      Name       => $Row[1],
      Comment    => $Row[2],
      ValidID    => $Row[3],
      CreateTime => $Row[4],
      ChangeTime => $Row[5]
    );

    push @List, \%TextModule;
  }

  return \@List;
}

=head2 CheckNameExists()
Check if a text module with the same name exists.

Example:
  my $NameExists = $TextModuleObject->CheckNameExists(
    ID => $GetParam{ID},  # Optional: ID to exclude
    Name => $GetParam{Name}
  );

Returns:
  $NameExists = true or false 
=cut

sub CheckNameExists {
  my ($Self, %Param) = @_;
  $Param{ID} ||= 0;

  my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

  $DBObject->Prepare(
    SQL => '
      SELECT id
      FROM text_module
      WHERE name = ?',
    Bind => [\$Param{Name}]
  );

  while (my @Row = $DBObject->FetchrowArray()) {
    $Param{Exists} = 1 if $Row[0] != $Param{ID};
  }

  return $Param{Exists};
}

=head2 GetTextModule()
Return a hash ref with all the information about a text module.

Example:
  my $TextModule = $TextModuleObject->GetTextModule(ID => 1);

Returns:
  $GetTextModule = {
    'ID' => '1',
    'Name' => 'ErsterTest',
    'Text' => '<p>Some HTML.</p>'
    'Comment' => 'My comment',
    'ValidID' => '1',
    'CreateTime' => '2019-09-11 19:00:00',
    'ChangeTime' => '2019-09-11 19:00:00',
  }
=cut

sub GetTextModule {
  my ($Self, %Param) = @_;

  my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

  $DBObject->Prepare(
    SQL => '
      SELECT id, name, text, comment, valid_id, create_time, change_time
      FROM text_module
      WHERE id = ?',
    Bind => [\$Param{ID}],
    Limit => 1
  );

  my %TextModule;
  while (my @Row = $DBObject->FetchrowArray()) {
    %TextModule = (
      ID         => $Row[0],
      Name       => $Row[1],
      Text       => $Row[2],
      Comment    => $Row[3],
      ValidID    => $Row[4],
      CreateTime => $Row[5],
      ChangeTime => $Row[6]
    );
  }

  return \%TextModule;
}

=head2 Update()
Update a text module.

Example:
  $TextModuleObject->Update(
    ID => 1,
    Name => 'Name1',
    Text => '<p>HTML block</p>',  # Optional
    Comment => 'My Block',  # Optional
    ValidID => $GetParam{ValidID}
  );

Returns:
  Nothing
=cut

sub Update {
  my ($Self, %Param) = @_;

  $Kernel::OM->Get('Kernel::System::DB')->Do(
    SQL => '
      UPDATE text_module
      SET name = ?, text = ?, comment = ?, valid_id = ?, change_time = CURRENT_TIMESTAMP
      WHERE id = ?',
    Bind => [
      \$Param{Name}, \$Param{Text}, \$Param{Comment}, \$Param{ValidID}, 
      \$Param{ID}]
  );

  return;
}

=head2 Insert()
Create a text module.

Example:
  $TextModuleObject->Insert(
    Name => 'Name1',
    Text => '<p>HTML block</p>',  # Optional
    Comment => 'My Block',  # Optional
    ValidID => $GetParam{ValidID}
  );

Returns:
  Nothing
=cut

sub Insert {
  my ($Self, %Param) = @_;

  $Kernel::OM->Get('Kernel::System::DB')->Do(
    SQL => '
      INSERT INTO text_module (name,  text, comment, valid_id, create_time, change_time)
      VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)',
    Bind => [\$Param{Name}, \$Param{Text}, \$Param{Comment}, \$Param{ValidID}]
  );

  return;
}

=head2 Delete()
Delete a text module

Example:
  my $Deleted = $TextModuleObject->Delete(ID => 1);

Returns:
  $Deleted = true or false
=cut

sub Delete {
  my ($Self, %Param) = @_;

  my $Result = $Kernel::OM->Get('Kernel::System::DB')->Do(
    SQL => 'DELETE FROM text_module WHERE ID = ?',
    Bind => [\$Param{ID}]
  );

  return $Result;
}

1;
