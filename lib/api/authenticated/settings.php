<?php

/** @var array $user */
/** @var array<string> $urlparts */

switch($urlparts[0]) {
	case 'gen-ai':
		validateMethod('POST');
		
		$tolerance = filter_input(INPUT_POST, 'tolerance', FILTER_VALIDATE_INT, [ 'options' => [ 'min' => -1, 'max' => 99 ] ]);
		if($tolerance === false)   fail(400, ['reason' => 'Malformed tolerance param.']);

		//NOTE(Rennorb): The api is cleaner if the 'don't care' value is -1, the internal storage however is 
		// 'don't care' === 0 because zero is a better default value.
		$tolerance += 1;

		$con->execute("UPDATE users SET genAiTolerance = $tolerance WHERE userId = {$user['userId']}"); // @security: $tolerance is validated to be int, $user['userId'] comes form the database and is int, therefore sql inert.

		good();

	case 'notifications':
		switch($urlparts[1]) {
			case 'followed-mods':
					validateMethod('POST');
					if(count($urlparts) < 3)   fail(400, ['reason' => 'Missing id.']);

					$modId = filter_var($urlparts[2], FILTER_VALIDATE_INT);
					if($modId === false)   fail(400, ['reason' => 'Malformed id query param.']);

					if(count($urlparts) === 3) {
						$newFlags = filter_input(INPUT_POST, 'new', FILTER_VALIDATE_INT);
						if($newFlags === null)   fail(400, ['reason' => 'Missing new settings value.']);
						if($newFlags === false)   fail(400, ['reason' => 'Malformed new settings value.']);

						$con->execute(<<<SQL
							INSERT INTO userFollowedMods
								(modId, userId, flags) VALUES (?, ?, ?)
							ON DUPLICATE KEY
								UPDATE flags = ?
						SQL, [$modId, $user['userId'], $newFlags, $newFlags]);
						if($con->affected_rows() == 1) {
							//NOTE(Rennorb): MariaDB / MySQL returns two rows affected on update.
							// For this reason we are able to differentiate between update and new insert without extra queries.
							$con->execute('UPDATE mods SET follows = follows + 1 WHERE modId = ?', [$modId]);
						}

						good();
					}

					switch($urlparts[3]) {
						case 'unfollow':
							validateMethod('POST');
							$con->execute('DELETE FROM userFollowedMods WHERE modId = ? AND userId = ?', [$modId, $user['userId']]);
							if($con->affected_rows()) {
								$con->execute('UPDATE mods SET follows = follows - 1 WHERE modId = ?', [$modId]);
							}

							good();
					}
		}
}