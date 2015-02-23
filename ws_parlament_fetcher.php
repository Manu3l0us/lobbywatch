<?php
require_once dirname(__FILE__) . '/public_html/settings/settings.php';
require_once dirname(__FILE__) . '/public_html/common/utils.php';
// Run: /opt/lampp/bin/php -f ws_parlament_fetcher.php

// http://www.parlament.ch/D/DOKUMENTATION/WEBSERVICES-OPENDATA/Seiten/default.aspx

// TODO multipage handling
// TODO Datenquelle angeben
// TODO historized handlen
// TODO historized fragen

$kommission_ids = array();

// $url = 'http://ws.parlament.ch/committees?ids=1;2;3&mainOnly=false&permanentOnly=true&currentOnly=true&lang=de&pageNumber=1&format=xml';
// $url = 'http://lobbywatch.ch/de/data/interface/v1/json/table/branche/flat/id/1';

// $json = fopen($url, 'r');
// $json = file_get_contents($url);
// $json = new_get_file_contents($url);

// Set user agent, otherwise only HTML will be returned instead of JSON, ref http://stackoverflow.com/questions/2107759/php-file-get-contents-and-headers
$options = array(
  'http'=>array(
    'method'=>"GET",
    'header'=>"Accept-language: en\r\n" .
              "Cookie: foo=bar\r\n" .  // check function.stream-context-create on php.net
              "User-Agent: Mozilla/5.0\r\n" // i.e. An iPad
  )
);

$context = stream_context_create($options);

get_PDO_lobbywatch_DB_connection();

for($page = 1, $hasMorePages = true, $i = 0; $hasMorePages; $page++) {
  global $db;

  $ws_parlament_url = "http://ws.parlament.ch/committees?currentOnly=true&mainOnly=true&permanentOnly=false&format=json&lang=de&pageNumber=$page";
  $json = file_get_contents($ws_parlament_url, false, $context);

  // $handle = @fopen($url, "r");
  // if ($handle) {
  //     while (($buffer = fgets($handle, 4096)) !== false) {
  //         echo $buffer;
  //     }
  //     if (!feof($handle)) {
  //         echo "Error: unexpected fgets() fail\n";
  //     }
  //     fclose($handle);
  // }

  // var_dump($json);
  $obj = json_decode($json);
  // var_dump($obj);

  $sql = "SELECT * FROM v_kommission kommission WHERE parlament_id = :kommission_parlament_id;";
  $stmt = $db->prepare($sql);

  $hasMorePages = false;
  print("Page: $page\n");
  foreach($obj as $kommission) {
    if(property_exists($kommission, 'hasMorePages')) {
      $hasMorePages = $kommission->hasMorePages;
    }
    $i++;

//     if ($i > 2) {
//       print("Aborted i > x\n");
//       return;
//     }
    $stmt->execute ( array(':kommission_parlament_id' => "$kommission->id") );
    $res = $stmt->fetchAll(PDO::FETCH_CLASS);
//     print_r($res);
    $ok = count($res) == 1;
    if ($ok) {
      $kommission_db = $res[0];
    } else {
      $kommission_db = null;
    }
    print($i . '. ' . ($ok ? '=' : '+') .' Kommission: ' . $kommission->id . ' ' . $kommission->abbreviation . ': ' . $kommission->name . ', '
         . $kommission->council->abbreviation . ', ' . $kommission->typeCode . ($ok ? ', id=' . $kommission_db->id : '') . "\n");
    show_members(array($kommission->id), 1, $context);
  }
}

function show_members(array $ids, $level = 1, $context) {
  global $db;

  $ids_str = implode(';', $ids);

  $sql = "SELECT parlamentarier.id, parlamentarier.name, parlamentarier.anzeige_name, parlamentarier.parlament_biografie_id, kommission.typ, kommission.art, kommission.parlament_id, kommission.mutter_kommission_id, 'NOK' as status FROM v_kommission kommission JOIN v_in_kommission in_kommission ON in_kommission.kommission_id = kommission.id JOIN v_parlamentarier_simple parlamentarier ON in_kommission.parlamentarier_id = parlamentarier.id WHERE in_kommission.bis IS NULL AND kommission.parlament_id = :kommission_parlament_id;"; // AND parlamentarier.parlament_biografie_id = :parlamentarier_parlament_id
  $stmt = $db->prepare($sql);

  for($page = 1, $hasMorePages = true, $i = 0, $j = 0; $hasMorePages; $page++) {
    $ws_parlament_url = "http://ws.parlament.ch/committees?ids=$ids_str&format=json&lang=de&subcom=true&pageNumber=$page";
    $json = file_get_contents($ws_parlament_url, false, $context);

    // $handle = @fopen($url, "r");
    // if ($handle) {
    //     while (($buffer = fgets($handle, 4096)) !== false) {
    //         echo $buffer;
    //     }
    //     if (!feof($handle)) {
    //         echo "Error: unexpected fgets() fail\n";
    //     }
    //     fclose($handle);
    // }

    // var_dump($json);
    $obj = json_decode($json);
    // var_dump($obj);

    $hasMorePages = false;
//     print("Mitgliederpage: $page\n");
    foreach($obj as $kommission) {
      if(property_exists($kommission, 'hasMorePages')) {
        $hasMorePages = $kommission->hasMorePages;
      }
      $i++;

      $stmt->execute ( array(':kommission_parlament_id' => "$kommission->id") );
      $db_members = $stmt->fetchAll(PDO::FETCH_CLASS);

      $memberNames = '';
      foreach($kommission->members as $member) {
        $memberNames .= $member->lastName . ', ';

//         print_r($db_members);
        $db_member = search_objects($db_members, 'parlament_biografie_id', $member->id);
//         print("Search $member->id\n");
//         print_r($db_member);
        if ($ok = count($db_member) == 1) {

          $db_member[0]->status = 'OK';
        }
//         print_r($db_member);
        //     print_r($res);

        print(str_repeat("\t", $level) . ($ok ? '= ' : '+ ') . $member->id . ' (' . $member->id . ') ' . $member->firstName . ' ' . $member->lastName . ' ' . $member->committeeFunction  . '=' . $member->committeeFunctionName . ', ' . $member->party . ', ' . $member->canton . ($ok ? ', id=' . $db_member[0]->id : '')  . "\n");
      }
//       print(str_repeat("\t", $level) . ' Kommissionsmitglieder: ' . $kommission->id . ' ' . $kommission->abbreviation . ': ' . $memberNames . "\n");
//       print_r($db_members);
      $db_members_NOK_in_DB = search_objects($db_members, 'status', 'NOK');
      foreach($db_members_NOK_in_DB as $member_NOK_in_DB) {
        print(str_repeat("\t", $level) . '- ' . $member_NOK_in_DB->name . ', id='. $member_NOK_in_DB->id . "\n");
      }

      foreach($kommission->subcommittees as $subCom) {
        $j++;
        print(str_repeat("\t", $level) . $j . '. Subkommission: ' . $subCom->id . ' ' . $subCom->abbreviation . ': ' . $subCom->name . ', '
            . $subCom->council->abbreviation . "\n");
        show_members(array($subCom->id), $level + 1, $context);
      }
    }
  }
}

// function to replace file_get_contents()
function new_get_file_contents($url) {
$ch = curl_init();
$timeout = 10; // set to zero for no timeout
curl_setopt ($ch, CURLOPT_URL, $url);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
$file_contents = curl_exec($ch); // take out the spaces of curl statement!!
curl_close($ch);
return $file_contents;
}