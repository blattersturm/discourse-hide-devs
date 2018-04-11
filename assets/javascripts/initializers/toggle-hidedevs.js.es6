// import libs.
import Composer from 'discourse/models/composer';
import {
  withPluginApi
} from 'discourse/lib/plugin-api';

export default {
  name: 'test-initializer',
  initialize() {
    // make sure the variable is safe to attach to the post.
    Composer.serializeOnCreate('hide_devs', 'hideDevs');

    withPluginApi('0.8.12', api => {
      const user = api.getCurrentUser();

      // Check if the user is in the hide_developers group.
      user.findDetails().then(function () {
        const groups = user.get('groups');
        const inHideGroup = groups.find((g) => g.name == "hide_developers");

        // if so, then enable the plugin.
        if (inHideGroup) {
          api.modifyClass('model:composer', {
            hideDevs: true
          })

          // Create the button and handle the event/action.
          api.onToolbarCreate(toolbar => {
            toolbar.addButton({
              id: "toggle-hide-devs-btn", // html class to append
              group: "extras", // button editor group/position
              icon: "user-secret", // icon (spy)
              action: "toggleHideDevs" // action name
            });
          });

          api.modifyClass('component:d-editor', {
            actions: {
              toggleHideDevs() { // handle the button pressed action.
                this.toggleProperty('outletArgs.composer.hideDevs');
                $(".toggle-hide-devs-btn").toggleClass("dis"); // toggle the button "dis" class.
              }
            }
          });
        }
      })
    })
  }
}
