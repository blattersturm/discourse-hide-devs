# name: discourse-hide-devs
# about: Hide developers discourse plugin.
# version: 2.0
# authors: CitizenFX Collective & Tom Grobbe
# url: https://github.com/blattersturm/discourse-hide-devs

enabled_site_setting :hide_devs_enabled

require_dependency 'post_creator'
require_dependency 'topic_creator'
require_dependency 'plugin/metadata'


after_initialize do

	::Post.register_custom_field_type('hide_devs', :boolean)
	register_post_custom_field_type('hide_devs', :boolean)
	add_permitted_post_create_param('hide_devs')
	hide = Group.find_by name: 'hide_developers'
	elementsGroup = Group.find_by name: 'elements'

	module ::HideDevs; end

	module ::HideDevs::WebHookTopicViewSerializerExtensions
		def include_post_stream?
			true
		end
	end

	module ::HideDevs::PostCreatorExtensions
		def initialize(user, opts)
			hide = Group.find_by name: 'hide_developers'
			elementsGroup = Group.find_by name: 'elements'

			super

			if ((user.group_ids.include? hide.id) && (opts[:hide_devs].to_s == "true"))
				@user = elementsGroup.users.sample
			else
				@user = user
			end
		end
	end

	class ::PostCreator
		prepend ::HideDevs::PostCreatorExtensions
	end

	class ::WebHookTopicViewSerializer
		prepend ::HideDevs::WebHookTopicViewSerializerExtensions
	end


	DiscourseEvent.on(:post_created) do |post, opts, user|
		next unless ((user.group_ids.include? hide.id) && (opts[:hide_devs].to_s == "true"))
		PostOwnerChanger.new(post_ids: [post.id],
				topic_id: post.topic_id,
				new_owner: elementsGroup.users.sample,
				acting_user: elementsGroup.users.sample,
				skip_revision: false).change_owner!
	end
end