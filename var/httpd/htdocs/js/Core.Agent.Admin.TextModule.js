// --
// Copyright (C) 2019–present Efflux GmbH, https://efflux.de/
// Part of the TextModule package.
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --

'use strict';

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

Core.Agent.Admin.TextModule = (function (TargetNS) {

  TargetNS.Init = function () {
    Core.UI.Table.InitTableFilter($('#FilterTextModules'), $('#TextModules'));
    TargetNS.InitTextModuleDelete();
  };

  TargetNS.InitTextModuleDelete = function () {
    $('.TextModuleDelete').on('click', function () {
      const TextModuleID = $(this).data('id');

      Core.UI.Dialog.ShowContentDialog(
        $('#DeleteTextModuleDialogContainer'),
        Core.Language.Translate('Delete this text module'),
        '240px',
        'Center',
        true,
        [
          {
            Class: 'Primary',
            Label: Core.Language.Translate('Confirm'),
            Function: function() {
              $('.Dialog .InnerContent .Center').text(Core.Language.Translate('Deleting text module ...'));
              $('.Dialog .Content .ContentFooter').remove();

              Core.AJAX.FunctionCall(
                Core.Config.Get('Baselink') + 'Action=AdminTextModule;Subaction=Delete',
                { ID: TextModuleID },
                function(res) {
                  if (res) {
                    $('#TextModuleID_' + parseInt(res, 10)).fadeOut(function() {
                      $(this).remove();
                    });
                    $('.Dialog .InnerContent .Center').text(Core.Language.Translate('Text module was deleted successfully.'));
                    window.setTimeout(function() {
                      Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                    }, 1000);  
                  } else {
                    $('.Dialog .InnerContent .Center').text(Core.Language.Translate('There was an error deleting the text module. Please check the logs for more information.'));
                  }
                }
              );
            }
          },
          {
            Label: Core.Language.Translate('Cancel'),
            Function: function () {
              Core.UI.Dialog.CloseDialog($('#DeleteTextModuleDialog'));
            }
          }
        ]
      );
      return false;
    });
  };

  Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

  return TargetNS;
}(Core.Agent.Admin.TextModule || {}));
