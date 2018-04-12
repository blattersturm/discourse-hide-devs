import { acceptance } from "helpers/qunit-helpers";
import { clearPopupMenuOptionsCallback } from "discourse/controllers/composer";

acceptance('Hide Devs', {
  loggedIn: true,
  settings: { hide_devs_enabled: true },
  beforeEach() {
    clearPopupMenuOptionsCallback();
  }
});

function findTextarea() {
  return find(".d-editor-input")[0];
}

test('hide devs', assert => {
  const popUpMenu = selectKit('.toolbar-popup-menu-options');

  visit("/");

  andThen(() => {
    assert.ok(exists('#create-topic'), 'the create button is visible');
  });

  click('#create-topic');
  popUpMenu.expand().selectRowByValue('toggleHideDevs');

  andThen(() => {
    assert.equal(
      find(".d-editor-input").val(),
      `<show>`,
      'it should contain the right output'
    );
  });
});