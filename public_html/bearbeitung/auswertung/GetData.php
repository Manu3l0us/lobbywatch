<?php

  require_once dirname(__FILE__) . "/../../settings/settings.php";
  require_once dirname(__FILE__) . "/../../common/utils.php";

    $username = $db_connection['reader_username'];
    $password = $db_connection['reader_password'];
    $host = $db_connection['server'];
    $database = $db_connection['database'];

//    $username = "root";
//    $password = "mysql";
//    $host = "localhost";
//    $database="lobbywatch";


  $optionen = array (
    PDO::ATTR_PERSISTENT => true
  );

  $db = new PDO ( 'mysql:host=' . $host .';dbname=' . $database . ';charset=utf8', $username, $password, $optionen );

  $db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );

   $option = urldecode($_GET["option"]);
  //    $id = urldecode($_GET["id"]);

   $cmd = "";
   $color_map = array();

   if ($option == "kommission") {
      $kommission_id = (int) @urldecode($_GET["id"]);
//       df($kommission_id, '$kommission_id init');
      $kommission_id = !isset($kommission_id) || !is_int($kommission_id) || $kommission_id == 0 ? 1 : $kommission_id;
//       df($kommission_id, '$kommission_id');
      $cmd = "select count(*) as value, 'nicht bearbeitet' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.eingabe_abgeschlossen_datum is null and
         p.kontrolliert_datum is null and
         p.autorisierung_verschickt_datum is null and
         p.autorisiert_datum is null and
         p.freigabe_datum is null
      union
      select count(*) as value, 'Erfasst' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.eingabe_abgeschlossen_datum is not null and
         p.kontrolliert_datum is null and
         p.autorisierung_verschickt_datum is null and
         p.autorisiert_datum is null and
         p.freigabe_datum is null
      union
      select count(*) as value, 'Kontrolliert' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.kontrolliert_datum is not null and
         p.autorisierung_verschickt_datum is null and
         p.autorisiert_datum is null and
         p.freigabe_datum is null
      union
      select count(*) as value, 'Verschickt' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.autorisierung_verschickt_datum is not null and
         p.autorisiert_datum is null and
         p.freigabe_datum is null
      union
      select count(*) as value, 'Autorisiert' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.autorisiert_datum is not null and
         p.freigabe_datum is null
      union
      select count(*) as value, 'Freigegeben' as label, null as color
      from v_parlamentarier p
      where
         exists (select * from in_kommission ik where ik.parlamentarier_id = p.id AND ik.kommission_id =  $kommission_id) and
         p.freigabe_datum is not null
      ";

      /*
      nicht bearbeitet: #FFFFB1
      erfasst: #FFFF00
      Kontrolliert: #FFA500
      Verschickt: #0000FF
      Autorisiert: #ADD8E6
      Freigegeben: #019E59
      */

      $color_map["nicht bearbeitet"] = "#FFFFBB";
      $color_map["Erfasst"] = "#FFFF00";
      $color_map["Kontrolliert"] = "#FFA500";
      $color_map["Verschickt"] = "#0000FF";
      $color_map["Autorisiert"] = "#ADD8E6";
      $color_map["Freigegeben"] = "#019E59";
   } elseif ($option == "ParlamentNachParteien") {
      $cmd = "
      select pa.abkuerzung as label, count(*) as value, pa.color
      from v_parlamentarier p
      inner join partei pa on pa.id = p.partei_id
      where p.ratstyp = 'NR'
      group by pa.abkuerzung
      order by 2, 1
      ";

      $color_map["CSP"] = "#FB7407";
      $color_map["MCR"] = "#0A7D3A";
      $color_map["EVP"] = "#FB7407";
      $color_map["Lega"] = "#0A7D3A";
      $color_map["BDP"] = "#FFE543";
      $color_map["GLP"] = "#88487F";
      $color_map["GPS"] = "#07F61E";
      $color_map["CVP"] = "#FB7407";
      $color_map["FDP"] = "#0A4BD6";
      $color_map["SP"] = "#FF0505";
      $color_map["SVP"] = "#0A7D3A";
   } elseif ($option == "bearbeitungsanteil") {
     $cmd = "
SELECT created_visa as label, COUNT(created_visa) as value, NULL as color  FROM (
SELECT *
FROM (
SELECT lower(created_visa) as created_visa FROM branche
UNION ALL
SELECT lower(created_visa) as created_visa FROM interessenbindung
UNION ALL
SELECT lower(created_visa) as created_visa FROM interessengruppe
UNION ALL
SELECT lower(created_visa) as created_visa FROM in_kommission
UNION ALL
SELECT lower(created_visa) as created_visa FROM kommission
UNION ALL
SELECT lower(created_visa) as created_visa FROM mandat
UNION ALL
SELECT lower(created_visa) as created_visa FROM organisation
UNION ALL
SELECT lower(created_visa) as created_visa FROM organisation_anhang
UNION ALL
SELECT lower(created_visa) as created_visa FROM organisation_beziehung
UNION ALL
SELECT lower(created_visa) as created_visa FROM organisation_jahr
UNION ALL
SELECT lower(created_visa) as created_visa FROM parlamentarier
UNION ALL
SELECT lower(created_visa) as created_visa FROM parlamentarier_anhang
UNION ALL
SELECT lower(created_visa) as created_visa FROM partei
UNION ALL
SELECT lower(created_visa) as created_visa FROM fraktion
UNION ALL
SELECT lower(created_visa) as created_visa FROM rat
UNION ALL
SELECT lower(created_visa) as created_visa FROM kanton
UNION ALL
SELECT lower(created_visa) as created_visa FROM kanton_jahr
UNION ALL
SELECT lower(created_visa) as created_visa FROM settings
UNION ALL
SELECT lower(created_visa) as created_visa FROM settings_category
UNION ALL
SELECT lower(created_visa) as created_visa FROM zutrittsberechtigung
UNION ALL
SELECT lower(created_visa) as created_visa FROM zutrittsberechtigung_anhang
) union_query
) total_created
GROUP BY label
ORDER BY value DESC;
";
         }

//    $query = $connection->query($cmd);
    $stmt = $db->prepare($cmd);

    $stmt->execute(array());
    $result = $stmt->fetchAll ( PDO::FETCH_ASSOC );

   if (!$result) {
      print_r($db->errorInfo());
      die;
   }

   $data = array();

   foreach($result as $row) {
      /*echo "Label: {$row["label"]}, value: {$row["value"]}, color:{$row["color"]} \n";*/

      $rowdata = [
         "label" => $row["label"],
         "value" => $row["value"],
         "color" => $row["color"] != null ? $row["value"] : @$color_map[$row["label"]]
      ];

      $data[] = $rowdata;
   }

   /*
   for ($x = 0; $x < mysql_num_rows($query); $x++) {
      $data[] = mysql_fetch_assoc($query);
   }
   */

   echo json_encode($data);

   $db = null;
