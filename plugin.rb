# name: discourse-hide-devs
# about: hide.. devs?
# version: 0.0.1
# authors: u

require_dependency 'post_creator'
require_dependency 'topic_creator'

after_initialize do
	devs = Group.find_by name: 'hide_developers'
	elements = Group.find_by name: 'elements'

	module ::HideDevs; end

	module ::HideDevs::WebHookTopicViewSerializerExtensions
		def include_post_stream?
			true
		end
	end

	module ::HideDevs::PostCreatorExtensions
		def initialize(user, opts)
			devs = Group.find_by name: 'hide_developers'
			elements = Group.find_by name: 'elements'

			super

			@user = elements.users.sample if user.group_ids.include? devs.id
		end
	end

	class ::PostCreator
		prepend ::HideDevs::PostCreatorExtensions
	end

	class ::WebHookTopicViewSerializer
		prepend ::HideDevs::WebHookTopicViewSerializerExtensions
	end

	DiscourseEvent.on(:post_created) do |post, opts, user|
		next unless user.group_ids.include? devs.id

		PostOwnerChanger.new( post_ids: [post.id],
				topic_id: post.topic_id,
				new_owner: elements.users.sample,
				acting_user: elements.users.sample,
				skip_revision: false ).change_owner!
	end
end
