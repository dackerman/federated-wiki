class federated_wiki_server {
	class {
		'federated_wiki' :
			persistent_device => '/dev/sdh',
			open_id_identifier => 'https://www.google.com/accounts/o8/id',
			source_git_repository =>
			'git://github.com/WardCunningham/Smallest-Federated-Wiki.git'
	}
}