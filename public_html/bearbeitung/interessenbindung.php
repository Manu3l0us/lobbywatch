<?php
// Processed by afterburner.sh


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                   ATTENTION!
 * If you see this message in your browser (Internet Explorer, Mozilla Firefox, Google Chrome, etc.)
 * this means that PHP is not properly installed on your web server. Please refer to the PHP manual
 * for more details: http://php.net/manual/install.php 
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */


    include_once dirname(__FILE__) . '/' . 'components/utils/check_utils.php';
    CheckPHPVersion();
    CheckTemplatesCacheFolderIsExistsAndWritable();


    include_once dirname(__FILE__) . '/' . 'phpgen_settings.php';
    include_once dirname(__FILE__) . '/' . 'database_engine/mysql_engine.php';
    include_once dirname(__FILE__) . '/' . 'components/page.php';
    include_once dirname(__FILE__) . '/' . 'authorization.php';

    function GetConnectionOptions()
    {
        $result = GetGlobalConnectionOptions();
        $result['client_encoding'] = 'utf8';
        GetApplication()->GetUserAuthorizationStrategy()->ApplyIdentityToConnectionOptions($result);
        return $result;
    }

    
    // OnGlobalBeforePageExecute event handler
    
    
    // OnBeforePageExecute event handler
    
    
    
    class interessenbindungPage extends Page
    {
        protected function DoBeforeCreate()
        {
            $this->dataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`interessenbindung`');
            $field = new IntegerField('id', null, null, true);
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, true);
            $field = new IntegerField('parlamentarier_id');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new IntegerField('organisation_id');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new StringField('art');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new StringField('funktion_im_gremium');
            $this->dataset->AddField($field, false);
            $field = new StringField('deklarationstyp');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new StringField('status');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new StringField('behoerden_vertreter');
            $this->dataset->AddField($field, false);
            $field = new IntegerField('verguetung');
            $this->dataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $this->dataset->AddField($field, false);
            $field = new StringField('quelle_url');
            $this->dataset->AddField($field, false);
            $field = new IntegerField('quelle_url_gueltig');
            $this->dataset->AddField($field, false);
            $field = new StringField('quelle');
            $this->dataset->AddField($field, false);
            $field = new DateField('von');
            $this->dataset->AddField($field, false);
            $field = new DateField('bis');
            $this->dataset->AddField($field, false);
            $field = new StringField('notizen');
            $this->dataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $this->dataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $this->dataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $this->dataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $this->dataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $this->dataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $this->dataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $this->dataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $this->dataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $this->dataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $this->dataset->AddField($field, false);
            $this->dataset->AddLookupField('parlamentarier_id', 'v_parlamentarier_simple', new IntegerField('id'), new StringField('anzeige_name', 'parlamentarier_id_anzeige_name', 'parlamentarier_id_anzeige_name_v_parlamentarier_simple'), 'parlamentarier_id_anzeige_name_v_parlamentarier_simple');
            $this->dataset->AddLookupField('organisation_id', 'v_organisation_simple', new IntegerField('id'), new StringField('anzeige_mixed', 'organisation_id_anzeige_mixed', 'organisation_id_anzeige_mixed_v_organisation_simple'), 'organisation_id_anzeige_mixed_v_organisation_simple');
        }
    
        protected function DoPrepare() {
    
        }
    
        protected function CreatePageNavigator()
        {
            $result = new CompositePageNavigator($this);
            
            $partitionNavigator = new CustomPageNavigator('partition', $this, $this->GetDataset(), $this->RenderText('Parlamentariername beginnt mit'), $result, 'partition');
            $partitionNavigator->OnGetPartitions->AddListener('partition_OnGetPartitions', $this);
            $partitionNavigator->OnGetPartitionCondition->AddListener('partition_OnGetPartitionCondition', $this);
            $partitionNavigator->SetAllowViewAllRecords(true);
            $partitionNavigator->SetNavigationStyle(NS_LIST);
            $result->AddPageNavigator($partitionNavigator);
            
            $partitionNavigator = new PageNavigator('pnav', $this, $this->dataset);
            $partitionNavigator->SetRowsPerPage(5);
            $result->AddPageNavigator($partitionNavigator);
            
            return $result;
        }
    
        public function GetPageList()
        {
            $currentPageCaption = $this->GetShortCaption();
            $result = new PageList($this);
            $result->AddGroup($this->RenderText('Subjektdaten'));
            $result->AddGroup($this->RenderText('Verbindungen'));
            $result->AddGroup($this->RenderText('Stammdaten'));
            $result->AddGroup($this->RenderText('Metadaten'));
            $result->AddGroup($this->RenderText('Misc'));
            if (GetCurrentUserGrantForDataSource('organisation')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity important-entity">Organisation</span>'), 'organisation.php', $this->RenderText('Organisation'), $currentPageCaption == $this->RenderText('<span class="entity important-entity">Organisation</span>'), false, $this->RenderText('Subjektdaten')));
            if (GetCurrentUserGrantForDataSource('parlamentarier')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity important-entity">Parlamentarier</span>'), 'parlamentarier.php', $this->RenderText('Parlamentarier'), $currentPageCaption == $this->RenderText('<span class="entity important-entity">Parlamentarier</span>'), false, $this->RenderText('Subjektdaten')));
            if (GetCurrentUserGrantForDataSource('person')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity important-entity">Person</span>'), 'person.php', $this->RenderText('Person'), $currentPageCaption == $this->RenderText('<span class="entity important-entity">Person</span>'), false, $this->RenderText('Subjektdaten')));
            if (GetCurrentUserGrantForDataSource('interessenbindung')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="relation" title="Interessenbindungen der Parlamentarier">Intereressenbind. von NR/SR</span>'), 'interessenbindung.php', $this->RenderText('Interessenbindung'), $currentPageCaption == $this->RenderText('<span class="relation" title="Interessenbindungen der Parlamentarier">Intereressenbind. von NR/SR</span>'), false, $this->RenderText('Verbindungen')));
            if (GetCurrentUserGrantForDataSource('zutrittsberechtigung')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="relation" title="Zutrittsberechtigungen f�r G�se ins Bundeshaus">Zutrittsberechtigung</span>'), 'zutrittsberechtigung.php', $this->RenderText('Zutrittsberechtigung'), $currentPageCaption == $this->RenderText('<span class="relation" title="Zutrittsberechtigungen f�r G�se ins Bundeshaus">Zutrittsberechtigung</span>'), false, $this->RenderText('Verbindungen')));
            if (GetCurrentUserGrantForDataSource('mandat')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="relation" title="Mandate der Zutrittsberechtigten">Mandate von Pers.</span>'), 'mandat.php', $this->RenderText('Mandat'), $currentPageCaption == $this->RenderText('<span class="relation" title="Mandate der Zutrittsberechtigten">Mandate von Pers.</span>'), false, $this->RenderText('Verbindungen')));
            if (GetCurrentUserGrantForDataSource('in_kommission')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="relation">In Kommission</span>'), 'in_kommission.php', $this->RenderText('In Kommission'), $currentPageCaption == $this->RenderText('<span class="relation">In Kommission</span>'), false, $this->RenderText('Verbindungen')));
            if (GetCurrentUserGrantForDataSource('organisation_beziehung')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="relation">Organisation Beziehung</span>'), 'organisation_beziehung.php', $this->RenderText('Organisation Beziehung'), $currentPageCaption == $this->RenderText('<span class="relation">Organisation Beziehung</span>'), false, $this->RenderText('Verbindungen')));
            if (GetCurrentUserGrantForDataSource('branche')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Branche</span>'), 'branche.php', $this->RenderText('Branche'), $currentPageCaption == $this->RenderText('<span class="entity">Branche</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('interessengruppe')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Lobbygruppe</span>'), 'interessengruppe.php', $this->RenderText('Lobbygruppe'), $currentPageCaption == $this->RenderText('<span class="entity">Lobbygruppe</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('kommission')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Kommission</span>'), 'kommission.php', $this->RenderText('Kommission'), $currentPageCaption == $this->RenderText('<span class="entity">Kommission</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('partei')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Partei</span>'), 'partei.php', $this->RenderText('Partei'), $currentPageCaption == $this->RenderText('<span class="entity">Partei</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('fraktion')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Fraktion</span>'), 'fraktion.php', $this->RenderText('Fraktion'), $currentPageCaption == $this->RenderText('<span class="entity">Fraktion</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('kanton')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="entity">Kanton</span>'), 'kanton.php', $this->RenderText('Kanton'), $currentPageCaption == $this->RenderText('<span class="entity">Kanton</span>'), false, $this->RenderText('Stammdaten')));
            if (GetCurrentUserGrantForDataSource('settings')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="settings">Settings</span>'), 'settings.php', $this->RenderText('Settings'), $currentPageCaption == $this->RenderText('<span class="settings">Settings</span>'), false, $this->RenderText('Metadaten')));
            if (GetCurrentUserGrantForDataSource('settings_category')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="settings">Settings Category</span>'), 'settings_category.php', $this->RenderText('Settings Category'), $currentPageCaption == $this->RenderText('<span class="settings">Settings Category</span>'), false, $this->RenderText('Metadaten')));
            if (GetCurrentUserGrantForDataSource('translation_source')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="settings">Translation Source</span>'), 'translation_source.php', $this->RenderText('Translation Source'), $currentPageCaption == $this->RenderText('<span class="settings">Translation Source</span>'), false, $this->RenderText('Metadaten')));
            if (GetCurrentUserGrantForDataSource('translation_target')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="settings">Translation Target</span>'), 'translation_target.php', $this->RenderText('Translation Target'), $currentPageCaption == $this->RenderText('<span class="settings">Translation Target</span>'), false, $this->RenderText('Metadaten')));
            if (GetCurrentUserGrantForDataSource('user')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="settings">User</span>'), 'user.php', $this->RenderText('User'), $currentPageCaption == $this->RenderText('<span class="settings">User</span>'), false, $this->RenderText('Metadaten')));
            if (GetCurrentUserGrantForDataSource('q_unvollstaendige_parlamentarier')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="view">Unvollst�ndige Parlamentarier</span>'), 'q_unvollstaendige_parlamentarier.php', $this->RenderText('Unvollst�ndige Parlamentarier'), $currentPageCaption == $this->RenderText('<span class="view">Unvollst�ndige Parlamentarier</span>'), false, $this->RenderText('Misc')));
            if (GetCurrentUserGrantForDataSource('q_unvollstaendige_zutrittsberechtigte')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="view">Unvollst�ndige Zutrittsberechtigte</span>'), 'q_unvollstaendige_zutrittsberechtigte.php', $this->RenderText('Unvollst�ndige Zutrittsberechtigte'), $currentPageCaption == $this->RenderText('<span class="view">Unvollst�ndige Zutrittsberechtigte</span>'), false, $this->RenderText('Misc')));
            if (GetCurrentUserGrantForDataSource('q_unvollstaendige_organisationen')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="view">Unvollst�ndige Organisationen</span>'), 'q_unvollstaendige_organisationen.php', $this->RenderText('Unvollst�ndige Organisationen'), $currentPageCaption == $this->RenderText('<span class="view">Unvollst�ndige Organisationen</span>'), false, $this->RenderText('Misc')));
            if (GetCurrentUserGrantForDataSource('q_last_updated_tables')->HasViewGrant())
                $result->AddPage(new PageLink($this->RenderText('<span class="view">Tabellenstand</span>'), 'tabellenstand.php', $this->RenderText('Tabellenstand'), $currentPageCaption == $this->RenderText('<span class="view">Tabellenstand</span>'), false, $this->RenderText('Misc')));
            
            if ( HasAdminPage() && GetApplication()->HasAdminGrantForCurrentUser() ) {
              $result->AddGroup('Admin area');
              $result->AddPage(new PageLink($this->GetLocalizerCaptions()->GetMessageString('AdminPage'), 'phpgen_admin.php', $this->GetLocalizerCaptions()->GetMessageString('AdminPage'), false, false, 'Admin area'));
              }

            add_more_navigation_links($result); // Afterburned
              {
            }
            return $result;
        }
    
        protected function CreateRssGenerator() {
            return setupRSS($this, $this->dataset); /*afterburner*/ 
        }
    
        protected function CreateGridSearchControl(Grid $grid)
        {
            $grid->UseFilter = true;
            $grid->SearchControl = new SimpleSearch('interessenbindungssearch', $this->dataset,
                array('id', 'parlamentarier_id_anzeige_name', 'organisation_id_anzeige_mixed', 'art', 'funktion_im_gremium', 'deklarationstyp', 'status', 'beschreibung', 'quelle_url', 'quelle', 'notizen'),
                array($this->RenderText('Id'), $this->RenderText('Parlamentarier'), $this->RenderText('Organisation'), $this->RenderText('Art'), $this->RenderText('Funktion im Gremium'), $this->RenderText('Deklarationstyp'), $this->RenderText('Status'), $this->RenderText('Beschreibung'), $this->RenderText('Quelle Url'), $this->RenderText('Quelle'), $this->RenderText('Notizen')),
                array(
                    '=' => $this->GetLocalizerCaptions()->GetMessageString('equals'),
                    '<>' => $this->GetLocalizerCaptions()->GetMessageString('doesNotEquals'),
                    '<' => $this->GetLocalizerCaptions()->GetMessageString('isLessThan'),
                    '<=' => $this->GetLocalizerCaptions()->GetMessageString('isLessThanOrEqualsTo'),
                    '>' => $this->GetLocalizerCaptions()->GetMessageString('isGreaterThan'),
                    '>=' => $this->GetLocalizerCaptions()->GetMessageString('isGreaterThanOrEqualsTo'),
                    'ILIKE' => $this->GetLocalizerCaptions()->GetMessageString('Like'),
                    'STARTS' => $this->GetLocalizerCaptions()->GetMessageString('StartsWith'),
                    'ENDS' => $this->GetLocalizerCaptions()->GetMessageString('EndsWith'),
                    'CONTAINS' => $this->GetLocalizerCaptions()->GetMessageString('Contains')
                    ), $this->GetLocalizerCaptions(), $this, 'CONTAINS'
                );
        }
    
        protected function CreateGridAdvancedSearchControl(Grid $grid)
        {
            $this->AdvancedSearchControl = new AdvancedSearchControl('interessenbindungasearch', $this->dataset, $this->GetLocalizerCaptions(), $this->GetColumnVariableContainer(), $this->CreateLinkBuilder());
            $this->AdvancedSearchControl->setTimerInterval(1000);
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('id', $this->RenderText('Id')));
            
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_parlamentarier_simple`');
            $field = new StringField('anzeige_name');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('nachname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vorname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('zweiter_vorname');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('rat_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kanton_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('kommissionen');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('partei_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('parteifunktion');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('fraktion_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('fraktionsfunktion');
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_seit');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_bis');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratswechsel');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_von');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_bis');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('beruf_interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('zivilstand');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('anzahl_kinder');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('militaerischer_grad_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('geschlecht');
            $lookupDataset->AddField($field, false);
            $field = new DateField('geburtstag');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateierweiterung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname_voll');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_mime_type');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kleinbild');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('sitzplatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('email');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('parlament_biografie_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('linkedin_profil_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('xing_profil_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('facebook_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('arbeitssprache');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_firma');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_ort');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_1');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_2');
            $lookupDataset->AddField($field, false);
            $field = new StringField('erfasst');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisierung_verschickt_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('autorisierung_verschickt_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('von');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('bis');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('geburtstag_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_seit_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_bis_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('von_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('bis_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_name', GetOrderTypeAsSQL(otAscending));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateLookupSearchInput('parlamentarier_id', $this->RenderText('Parlamentarier'), $lookupDataset, 'id', 'anzeige_name', false, 8));
            
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_organisation_simple`');
            $field = new StringField('anzeige_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_mixed');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_it');
            $lookupDataset->AddField($field, false);
            $field = new StringField('uid');
            $lookupDataset->AddField($field, false);
            $field = new StringField('ort');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('land_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessenraum_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('rechtsform');
            $lookupDataset->AddField($field, false);
            $field = new StringField('typ');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vernehmlassung');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe2_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe3_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('branche_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new StringField('handelsregister_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_mixed', GetOrderTypeAsSQL(otAscending));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateLookupSearchInput('organisation_id', $this->RenderText('Organisation'), $lookupDataset, 'id', 'anzeige_mixed', false, 8));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('art', $this->RenderText('Art')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('funktion_im_gremium', $this->RenderText('Funktion im Gremium')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('deklarationstyp', $this->RenderText('Deklarationstyp')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('status', $this->RenderText('Status')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('behoerden_vertreter', $this->RenderText('Beh�rdenvertreter')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('von', $this->RenderText('Von'), 'd.m.Y'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('bis', $this->RenderText('Bis'), 'd.m.Y'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('verguetung', $this->RenderText('Verguetung')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('beschreibung', $this->RenderText('Beschreibung')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('quelle_url', $this->RenderText('Quelle Url')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('quelle', $this->RenderText('Quelle')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('notizen', $this->RenderText('Notizen')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('eingabe_abgeschlossen_visa', $this->RenderText('Eingabe Abgeschlossen Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('eingabe_abgeschlossen_datum', $this->RenderText('Eingabe Abgeschlossen Datum'), 'd.m.Y H:i:s'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('kontrolliert_visa', $this->RenderText('Kontrolliert Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('kontrolliert_datum', $this->RenderText('Kontrolliert Datum'), 'd.m.Y H:i:s'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('autorisiert_visa', $this->RenderText('Autorisiert Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('autorisiert_datum', $this->RenderText('Autorisiert Datum'), 'd.m.Y'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('freigabe_visa', $this->RenderText('Freigabe Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('freigabe_datum', $this->RenderText('Freigabe Datum'), 'd.m.Y H:i:s'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('created_visa', $this->RenderText('Created Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('created_date', $this->RenderText('Created Date'), 'd.m.Y H:i:s'));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateStringSearchInput('updated_visa', $this->RenderText('Updated Visa')));
            $this->AdvancedSearchControl->AddSearchColumn($this->AdvancedSearchControl->CreateDateTimeSearchInput('updated_date', $this->RenderText('Updated Date'), 'd.m.Y H:i:s'));
        }
    
        protected function AddOperationsColumns(Grid $grid)
        {
            $actionsBandName = 'actions';
            $grid->AddBandToBegin($actionsBandName, $this->GetLocalizerCaptions()->GetMessageString('Actions'), true);
            if ($this->GetSecurityInfo()->HasViewGrant())
            {
                $column = new RowOperationByLinkColumn($this->GetLocalizerCaptions()->GetMessageString('View'), OPERATION_VIEW, $this->dataset);
                $grid->AddViewColumn($column, $actionsBandName);
                $column->SetImagePath('images/view_action.png');
            }
            if ($this->GetSecurityInfo()->HasEditGrant())
            {
                $column = new RowOperationByLinkColumn($this->GetLocalizerCaptions()->GetMessageString('Edit'), OPERATION_EDIT, $this->dataset);
                $grid->AddViewColumn($column, $actionsBandName);
                $column->SetImagePath('images/edit_action.png');
                $column->OnShow->AddListener('ShowEditButtonHandler', $this);
            }
            if ($this->GetSecurityInfo()->HasDeleteGrant())
            {
                $column = new RowOperationByLinkColumn($this->GetLocalizerCaptions()->GetMessageString('Delete'), OPERATION_DELETE, $this->dataset);
                $grid->AddViewColumn($column, $actionsBandName);
                $column->SetImagePath('images/delete_action.png');
                $column->OnShow->AddListener('ShowDeleteButtonHandler', $this);
            $column->SetAdditionalAttribute("data-modal-delete", "true");
            $column->SetAdditionalAttribute("data-delete-handler-name", $this->GetModalGridDeleteHandler());
            }
            if ($this->GetSecurityInfo()->HasAddGrant())
            {
                $column = new RowOperationByLinkColumn($this->GetLocalizerCaptions()->GetMessageString('Copy'), OPERATION_COPY, $this->dataset);
                $grid->AddViewColumn($column, $actionsBandName);
                $column->SetImagePath('images/copy_action.png');
            }
        }
    
        protected function AddFieldColumns(Grid $grid)
        {
            //
            // View column for id field
            //
            $column = new TextViewColumn('id', 'Id', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Technischer Schl�ssel der Interessenbindung'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for anzeige_name field
            //
            $column = new TextViewColumn('parlamentarier_id_anzeige_name', 'Parlamentarier', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'parlamentarier.php?operation=view&pk0=%parlamentarier_id%' , '_self');
            $column = new DivTagViewColumnDecorator($column);
            $column->Bold = true;
            $column->SetDescription($this->RenderText('Fremdschl�ssel Parlamentarier'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for anzeige_mixed field
            //
            $column = new TextViewColumn('organisation_id_anzeige_mixed', 'Organisation', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'organisation.php?operation=view&pk0=%organisation_id%' , '_self');
            $column->SetDescription($this->RenderText('Fremdschl�ssel Organisation'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for art field
            //
            $column = new TextViewColumn('art', 'Art', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Art der Interessenbindung'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for funktion_im_gremium field
            //
            $column = new TextViewColumn('funktion_im_gremium', 'Funktion im Gremium', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Funktion innerhalb des Gremiums, z.B. Pr�sident in einem Vorstand einer AG entspricht einem Verwaltungsratspr�sidenten, Pr�sident einer Gesch�ftsleitung entspricht einem CEO.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for deklarationstyp field
            //
            $column = new TextViewColumn('deklarationstyp', 'Deklarationstyp', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Ist diese Interessenbindung deklarationspflichtig? Art. 11 Offenlegungspflichten:<ol><li>Beim Amtsantritt und jeweils auf Jahresbeginn unterrichtet jedes Ratsmitglied das B�ro schriftlich �ber seine:<ol><li>beruflichen T�tigkeiten;<li>T�tigkeiten in F�hrungs- und Aufsichtsgremien sowie Beir�ten und �hnlichen Gremien von schweizerischen und ausl�ndischen K�rperschaften, Anstalten und Stiftungen des privaten und des �ffentlichen Rechts;<li>Beratungs- oder Expertent�tigkeiten f�r Bundesstellen;<li>dauernden Leitungs- oder Beratungst�tigkeiten f�r schweizerische und ausl�ndische Interessengruppen; <li>e. Mitwirkung in Kommissionen und anderen Organen des Bundes.</ol></ol>'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for status field
            //
            $column = new TextViewColumn('status', 'Status', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Status der Interessenbindung'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for behoerden_vertreter field
            //
            $column = new TextViewColumn('behoerden_vertreter', 'Beh�rdenvertreter', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Entstand diese Interessenbindung als Behoerdenvertreter von amteswegen? Beispielsweise weil ein Regierungsrat in einem Verwaltungsrat von amteswegen einsitz nimmt.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for von field
            //
            $column = new DateTimeViewColumn('von', 'Von', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Beginn der Interessenbindung, leer (NULL) = unbekannt'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for bis field
            //
            $column = new DateTimeViewColumn('bis', 'Bis', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Ende der Interessenbindung, leer (NULL) = aktuell g�ltig, nicht leer = historischer Eintrag'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for verguetung field
            //
            $column = new TextViewColumn('verguetung', 'Verguetung', $this->dataset);
            $column->SetOrderable(true);
            $column = new CurrencyFormatValueViewColumnDecorator($column, 0, '\'', '', $this->RenderText('Fr.'));
            $column->SetDescription($this->RenderText('J�hrliche Verg�tung CHF f�r T�tigkeiten aus dieser Interessenbindung, z.B. Entsch�digung f�r Beiratsfunktion.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_beschreibung_handler_list');
            $column->SetReplaceLFByBR(true);
            $column->SetDescription($this->RenderText('Bezeichung der Interessenbindung. M�glichst kurz. Wird nicht ausgewertet, jedoch angezeigt.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_quelle_url_handler_list');
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, '%quelle_url%' , '');
            $column->SetDescription($this->RenderText('URL der Quelle; zum Beleg'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_quelle_handler_list');
            $column->SetDescription($this->RenderText('Quellenangabe, Format: "[Publikation], DD.MM.YYYY", falls vorhanden bitte die URL im Feld "Quelle URL" auch hinzuf�gen'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_notizen_handler_list');
            $column->SetReplaceLFByBR(true);
            $column->SetDescription($this->RenderText('Interne Notizen zu diesem Eintrag. Eintr�ge am besten mit Datum und Visa versehen.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_visa field
            //
            $column = new TextViewColumn('eingabe_abgeschlossen_visa', 'Eingabe Abgeschlossen Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('K�rzel der Person, welche die Eingabe abgeschlossen hat.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_datum field
            //
            $column = new DateTimeViewColumn('eingabe_abgeschlossen_datum', 'Eingabe Abgeschlossen Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Die Eingabe ist f�r den Ersteller der Eintr�ge abgeschlossen und bereit f�r die Kontrolle. (Leer/NULL bedeutet, dass die Eingabe noch im Gange ist.)'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for kontrolliert_visa field
            //
            $column = new TextViewColumn('kontrolliert_visa', 'Kontrolliert Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('K�rzel der Person, welche die Eingabe kontrolliert hat.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for kontrolliert_datum field
            //
            $column = new DateTimeViewColumn('kontrolliert_datum', 'Kontrolliert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Der Eintrag wurde durch eine zweite Person am angegebenen Datum kontrolliert. (Leer/NULL bedeutet noch nicht kontrolliert.)'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for autorisiert_visa field
            //
            $column = new TextViewColumn('autorisiert_visa', 'Autorisiert Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Autorisiert durch. Sonstige Angaben als Notiz erfassen.'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for autorisiert_datum field
            //
            $column = new DateTimeViewColumn('autorisiert_datum', 'Autorisiert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Autorisiert am'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for freigabe_visa field
            //
            $column = new TextViewColumn('freigabe_visa', 'Freigabe Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Freigabe von (Freigabe = Daten sind fertig)'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for freigabe_datum field
            //
            $column = new DateTimeViewColumn('freigabe_datum', 'Freigabe Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Freigabedatum (Freigabe = Daten sind fertig)'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for created_visa field
            //
            $column = new TextViewColumn('created_visa', 'Created Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Erstellt von'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for created_date field
            //
            $column = new DateTimeViewColumn('created_date', 'Created Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Erstellt am'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for updated_visa field
            //
            $column = new TextViewColumn('updated_visa', 'Updated Visa', $this->dataset);
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Abge�ndert von'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
            
            //
            // View column for updated_date field
            //
            $column = new DateTimeViewColumn('updated_date', 'Updated Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $column->SetDescription($this->RenderText('Abge�ndert am'));
            $column->SetFixedWidth(null);
            $grid->AddViewColumn($column);
        }
    
        protected function AddSingleRecordViewColumns(Grid $grid)
        {
            //
            // View column for id field
            //
            $column = new TextViewColumn('id', 'Id', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for anzeige_name field
            //
            $column = new TextViewColumn('parlamentarier_id_anzeige_name', 'Parlamentarier', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'parlamentarier.php?operation=view&pk0=%parlamentarier_id%' , '_self');
            $column = new DivTagViewColumnDecorator($column);
            $column->Bold = true;
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for anzeige_mixed field
            //
            $column = new TextViewColumn('organisation_id_anzeige_mixed', 'Organisation', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'organisation.php?operation=view&pk0=%organisation_id%' , '_self');
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for art field
            //
            $column = new TextViewColumn('art', 'Art', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for funktion_im_gremium field
            //
            $column = new TextViewColumn('funktion_im_gremium', 'Funktion im Gremium', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for deklarationstyp field
            //
            $column = new TextViewColumn('deklarationstyp', 'Deklarationstyp', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for status field
            //
            $column = new TextViewColumn('status', 'Status', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for behoerden_vertreter field
            //
            $column = new TextViewColumn('behoerden_vertreter', 'Beh�rdenvertreter', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for von field
            //
            $column = new DateTimeViewColumn('von', 'Von', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for bis field
            //
            $column = new DateTimeViewColumn('bis', 'Bis', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for verguetung field
            //
            $column = new TextViewColumn('verguetung', 'Verguetung', $this->dataset);
            $column->SetOrderable(true);
            $column = new CurrencyFormatValueViewColumnDecorator($column, 0, '\'', '', $this->RenderText('Fr.'));
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_beschreibung_handler_view');
            $column->SetReplaceLFByBR(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_quelle_url_handler_view');
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, '%quelle_url%' , '');
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_quelle_handler_view');
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $column->SetMaxLength(75);
            $column->SetFullTextWindowHandlerName('interessenbindungGrid_notizen_handler_view');
            $column->SetReplaceLFByBR(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_visa field
            //
            $column = new TextViewColumn('eingabe_abgeschlossen_visa', 'Eingabe Abgeschlossen Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_datum field
            //
            $column = new DateTimeViewColumn('eingabe_abgeschlossen_datum', 'Eingabe Abgeschlossen Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for kontrolliert_visa field
            //
            $column = new TextViewColumn('kontrolliert_visa', 'Kontrolliert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for kontrolliert_datum field
            //
            $column = new DateTimeViewColumn('kontrolliert_datum', 'Kontrolliert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for autorisiert_visa field
            //
            $column = new TextViewColumn('autorisiert_visa', 'Autorisiert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for autorisiert_datum field
            //
            $column = new DateTimeViewColumn('autorisiert_datum', 'Autorisiert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for freigabe_visa field
            //
            $column = new TextViewColumn('freigabe_visa', 'Freigabe Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for freigabe_datum field
            //
            $column = new DateTimeViewColumn('freigabe_datum', 'Freigabe Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for created_visa field
            //
            $column = new TextViewColumn('created_visa', 'Created Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for created_date field
            //
            $column = new DateTimeViewColumn('created_date', 'Created Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for updated_visa field
            //
            $column = new TextViewColumn('updated_visa', 'Updated Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
            
            //
            // View column for updated_date field
            //
            $column = new DateTimeViewColumn('updated_date', 'Updated Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddSingleRecordViewColumn($column);
        }
    
        protected function AddEditColumns(Grid $grid)
        {
            //
            // Edit column for parlamentarier_id field
            //
            $editor = new AutocomleteComboBox('parlamentarier_id_edit', $this->CreateLinkBuilder());
            $editor->SetSize('250px');
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_parlamentarier_simple`');
            $field = new StringField('anzeige_name');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('nachname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vorname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('zweiter_vorname');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('rat_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kanton_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('kommissionen');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('partei_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('parteifunktion');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('fraktion_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('fraktionsfunktion');
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_seit');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_bis');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratswechsel');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_von');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_bis');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('beruf_interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('zivilstand');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('anzahl_kinder');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('militaerischer_grad_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('geschlecht');
            $lookupDataset->AddField($field, false);
            $field = new DateField('geburtstag');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateierweiterung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname_voll');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_mime_type');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kleinbild');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('sitzplatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('email');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('parlament_biografie_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('linkedin_profil_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('xing_profil_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('facebook_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('arbeitssprache');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_firma');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_ort');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_1');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_2');
            $lookupDataset->AddField($field, false);
            $field = new StringField('erfasst');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisierung_verschickt_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('autorisierung_verschickt_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('von');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('bis');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('geburtstag_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_seit_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_bis_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('von_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('bis_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_name', GetOrderTypeAsSQL(otAscending));
            $editColumn = new DynamicLookupEditColumn('Parlamentarier', 'parlamentarier_id', 'parlamentarier_id_anzeige_name', 'edit_parlamentarier_id_anzeige_name_search', $editor, $this->dataset, $lookupDataset, 'id', 'anzeige_name', '');
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for organisation_id field
            //
            $editor = new AutocomleteComboBox('organisation_id_edit', $this->CreateLinkBuilder());
            $editor->SetSize('250px');
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_organisation_simple`');
            $field = new StringField('anzeige_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_mixed');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_it');
            $lookupDataset->AddField($field, false);
            $field = new StringField('uid');
            $lookupDataset->AddField($field, false);
            $field = new StringField('ort');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('land_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessenraum_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('rechtsform');
            $lookupDataset->AddField($field, false);
            $field = new StringField('typ');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vernehmlassung');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe2_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe3_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('branche_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new StringField('handelsregister_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_mixed', GetOrderTypeAsSQL(otAscending));
            $editColumn = new DynamicLookupEditColumn('Organisation', 'organisation_id', 'organisation_id_anzeige_mixed', 'edit_organisation_id_anzeige_mixed_search', $editor, $this->dataset, $lookupDataset, 'id', 'anzeige_mixed', '');
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for art field
            //
            $editor = new ComboBox('art_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('mitglied', $this->RenderText('Mitglied / Membre'));
            $editor->AddValue('geschaeftsfuehrend', $this->RenderText('Gesch�ftsf�hrend / en poste de direction'));
            $editor->AddValue('vorstand', $this->RenderText('Vorstand/Verwaltungsrat/Stiftungsrat / Conseil d\'administration/fondation'));
            $editor->AddValue('taetig', $this->RenderText('T�tig / actif'));
            $editor->AddValue('beirat', $this->RenderText('Beirat/Patronatskomitee/Expertenkommission/Advisory Board / Conseil/Comit� de patronage/Commission d\'experts/Advisory Board'));
            $editor->AddValue('finanziell', $this->RenderText('Finanziell (Aktienbesitz) / Financier (Actions)'));
            $editor->AddValue('gesellschafter', $this->RenderText('GmbH-Gesellschafter / Soci�taire-SARL'));
            $editColumn = new CustomEditColumn('Art', 'art', $editor, $this->dataset);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for funktion_im_gremium field
            //
            $editor = new ComboBox('funktion_im_gremium_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('praesident', $this->RenderText('Pr�sident / Pr�sident'));
            $editor->AddValue('vizepraesident', $this->RenderText('Vizepr�sident / Vice-pr�sident'));
            $editor->AddValue('mitglied', $this->RenderText('Mitglied / Membre'));
            $editColumn = new CustomEditColumn('Funktion im Gremium', 'funktion_im_gremium', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for deklarationstyp field
            //
            $editor = new ComboBox('deklarationstyp_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('deklarationspflichtig', $this->RenderText('deklarationspflichtig / doit �tre d�clar�'));
            $editor->AddValue('nicht deklarationspflicht', $this->RenderText('nicht deklarationspflicht / ne doit pas �tre d�clar�'));
            $editColumn = new CustomEditColumn('Deklarationstyp', 'deklarationstyp', $editor, $this->dataset);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for status field
            //
            $editor = new ComboBox('status_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('deklariert', $this->RenderText('deklariert / d�clar�(e)'));
            $editor->AddValue('nicht-deklariert', $this->RenderText('nicht-deklariert / non-d�clar�(e)'));
            $editColumn = new CustomEditColumn('Status', 'status', $editor, $this->dataset);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for behoerden_vertreter field
            //
            $editor = new ComboBox('behoerden_vertreter_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('J', $this->RenderText('Ja / Oui'));
            $editor->AddValue('N', $this->RenderText('Nein / Non'));
            $editColumn = new CustomEditColumn('Beh�rdenvertreter', 'behoerden_vertreter', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for von field
            //
            $editor = new DateTimeEdit('von_edit', false, 'd.m.Y', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Von', 'von', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for bis field
            //
            $editor = new DateTimeEdit('bis_edit', false, 'd.m.Y', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Bis', 'bis', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for verguetung field
            //
            $editor = new TextEdit('verguetung_edit');
            $editor->SetSuffix($this->RenderText('Fr. / Jahr'));
            $editColumn = new CustomEditColumn('Verguetung', 'verguetung', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $validator = new DigitsValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('DigitsValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for beschreibung field
            //
            $editor = new TextEdit('beschreibung_edit');
            $editor->SetSize(80);
            $editor->SetMaxLength(150);
            $editColumn = new CustomEditColumn('Beschreibung', 'beschreibung', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for quelle_url field
            //
            $editor = new TextEdit('quelle_url_edit');
            $editor->SetSize(70);
            $editor->SetMaxLength(255);
            $editColumn = new CustomEditColumn('Quelle Url', 'quelle_url', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $validator = new UrlValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('UrlValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for quelle field
            //
            $editor = new TextEdit('quelle_edit');
            $editor->SetSize(80);
            $editor->SetMaxLength(80);
            $editColumn = new CustomEditColumn('Quelle', 'quelle', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for notizen field
            //
            $editor = new TextAreaEdit('notizen_edit', 50, 8);
            $editColumn = new CustomEditColumn('Notizen', 'notizen', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for eingabe_abgeschlossen_visa field
            //
            $editor = new TextEdit('eingabe_abgeschlossen_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Eingabe Abgeschlossen Visa', 'eingabe_abgeschlossen_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for eingabe_abgeschlossen_datum field
            //
            $editor = new DateTimeEdit('eingabe_abgeschlossen_datum_edit', true, 'd.m.Y H:i:s', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Eingabe Abgeschlossen Datum', 'eingabe_abgeschlossen_datum', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for kontrolliert_visa field
            //
            $editor = new TextEdit('kontrolliert_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Kontrolliert Visa', 'kontrolliert_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for kontrolliert_datum field
            //
            $editor = new DateTimeEdit('kontrolliert_datum_edit', true, 'd.m.Y H:i:s', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Kontrolliert Datum', 'kontrolliert_datum', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for autorisiert_visa field
            //
            $editor = new TextEdit('autorisiert_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Autorisiert Visa', 'autorisiert_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for autorisiert_datum field
            //
            $editor = new DateTimeEdit('autorisiert_datum_edit', true, 'd.m.Y', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Autorisiert Datum', 'autorisiert_datum', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for freigabe_visa field
            //
            $editor = new TextEdit('freigabe_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Freigabe Visa', 'freigabe_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for freigabe_datum field
            //
            $editor = new DateTimeEdit('freigabe_datum_edit', true, 'd.m.Y H:i:s', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Freigabe Datum', 'freigabe_datum', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for created_visa field
            //
            $editor = new TextEdit('created_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Created Visa', 'created_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for created_date field
            //
            $editor = new DateTimeEdit('created_date_edit', true, 'd.m.Y H:i:s', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Created Date', 'created_date', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for updated_visa field
            //
            $editor = new TextEdit('updated_visa_edit');
            $editor->SetSize(10);
            $editor->SetMaxLength(10);
            $editColumn = new CustomEditColumn('Updated Visa', 'updated_visa', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
            
            //
            // Edit column for updated_date field
            //
            $editor = new DateTimeEdit('updated_date_edit', true, 'd.m.Y H:i:s', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Updated Date', 'updated_date', $editor, $this->dataset);
            $editColumn->SetReadOnly(true);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddEditColumn($editColumn);
        }
    
        protected function AddInsertColumns(Grid $grid)
        {
            //
            // Edit column for parlamentarier_id field
            //
            $editor = new AutocomleteComboBox('parlamentarier_id_edit', $this->CreateLinkBuilder());
            $editor->SetSize('250px');
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_parlamentarier_simple`');
            $field = new StringField('anzeige_name');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('nachname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vorname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('zweiter_vorname');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('rat_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kanton_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('kommissionen');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('partei_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('parteifunktion');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('fraktion_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('fraktionsfunktion');
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_seit');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_bis');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratswechsel');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_von');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_bis');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('beruf_interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('zivilstand');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('anzahl_kinder');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('militaerischer_grad_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('geschlecht');
            $lookupDataset->AddField($field, false);
            $field = new DateField('geburtstag');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateierweiterung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname_voll');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_mime_type');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kleinbild');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('sitzplatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('email');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('parlament_biografie_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('linkedin_profil_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('xing_profil_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('facebook_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('arbeitssprache');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_firma');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_ort');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_1');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_2');
            $lookupDataset->AddField($field, false);
            $field = new StringField('erfasst');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisierung_verschickt_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('autorisierung_verschickt_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('von');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('bis');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('geburtstag_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_seit_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_bis_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('von_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('bis_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_name', GetOrderTypeAsSQL(otAscending));
            $editColumn = new DynamicLookupEditColumn('Parlamentarier', 'parlamentarier_id', 'parlamentarier_id_anzeige_name', 'insert_parlamentarier_id_anzeige_name_search', $editor, $this->dataset, $lookupDataset, 'id', 'anzeige_name', '');
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for organisation_id field
            //
            $editor = new AutocomleteComboBox('organisation_id_edit', $this->CreateLinkBuilder());
            $editor->SetSize('250px');
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_organisation_simple`');
            $field = new StringField('anzeige_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_mixed');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_it');
            $lookupDataset->AddField($field, false);
            $field = new StringField('uid');
            $lookupDataset->AddField($field, false);
            $field = new StringField('ort');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('land_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessenraum_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('rechtsform');
            $lookupDataset->AddField($field, false);
            $field = new StringField('typ');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vernehmlassung');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe2_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe3_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('branche_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new StringField('handelsregister_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_mixed', GetOrderTypeAsSQL(otAscending));
            $editColumn = new DynamicLookupEditColumn('Organisation', 'organisation_id', 'organisation_id_anzeige_mixed', 'insert_organisation_id_anzeige_mixed_search', $editor, $this->dataset, $lookupDataset, 'id', 'anzeige_mixed', '');
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for art field
            //
            $editor = new ComboBox('art_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('mitglied', $this->RenderText('Mitglied / Membre'));
            $editor->AddValue('geschaeftsfuehrend', $this->RenderText('Gesch�ftsf�hrend / en poste de direction'));
            $editor->AddValue('vorstand', $this->RenderText('Vorstand/Verwaltungsrat/Stiftungsrat / Conseil d\'administration/fondation'));
            $editor->AddValue('taetig', $this->RenderText('T�tig / actif'));
            $editor->AddValue('beirat', $this->RenderText('Beirat/Patronatskomitee/Expertenkommission/Advisory Board / Conseil/Comit� de patronage/Commission d\'experts/Advisory Board'));
            $editor->AddValue('finanziell', $this->RenderText('Finanziell (Aktienbesitz) / Financier (Actions)'));
            $editor->AddValue('gesellschafter', $this->RenderText('GmbH-Gesellschafter / Soci�taire-SARL'));
            $editColumn = new CustomEditColumn('Art', 'art', $editor, $this->dataset);
            $editColumn->SetAllowSetToDefault(false); /*afterburner*/ 
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for funktion_im_gremium field
            //
            $editor = new ComboBox('funktion_im_gremium_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('praesident', $this->RenderText('Pr�sident / Pr�sident'));
            $editor->AddValue('vizepraesident', $this->RenderText('Vizepr�sident / Vice-pr�sident'));
            $editor->AddValue('mitglied', $this->RenderText('Mitglied / Membre'));
            $editColumn = new CustomEditColumn('Funktion im Gremium', 'funktion_im_gremium', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for deklarationstyp field
            //
            $editor = new ComboBox('deklarationstyp_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('deklarationspflichtig', $this->RenderText('deklarationspflichtig / doit �tre d�clar�'));
            $editor->AddValue('nicht deklarationspflicht', $this->RenderText('nicht deklarationspflicht / ne doit pas �tre d�clar�'));
            $editColumn = new CustomEditColumn('Deklarationstyp', 'deklarationstyp', $editor, $this->dataset);
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for status field
            //
            $editor = new ComboBox('status_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('deklariert', $this->RenderText('deklariert / d�clar�(e)'));
            $editor->AddValue('nicht-deklariert', $this->RenderText('nicht-deklariert / non-d�clar�(e)'));
            $editColumn = new CustomEditColumn('Status', 'status', $editor, $this->dataset);
            $editColumn->SetAllowSetToDefault(false); /*afterburner*/ 
            $validator = new RequiredValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('RequiredValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for behoerden_vertreter field
            //
            $editor = new ComboBox('behoerden_vertreter_edit', $this->GetLocalizerCaptions()->GetMessageString('PleaseSelect'));
            $editor->AddValue('J', $this->RenderText('Ja / Oui'));
            $editor->AddValue('N', $this->RenderText('Nein / Non'));
            $editColumn = new CustomEditColumn('Beh�rdenvertreter', 'behoerden_vertreter', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for von field
            //
            $editor = new DateTimeEdit('von_edit', false, 'd.m.Y', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Von', 'von', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for bis field
            //
            $editor = new DateTimeEdit('bis_edit', false, 'd.m.Y', GetFirstDayOfWeek());
            $editColumn = new CustomEditColumn('Bis', 'bis', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for verguetung field
            //
            $editor = new TextEdit('verguetung_edit');
            $editor->SetSuffix($this->RenderText('Fr. / Jahr'));
            $editColumn = new CustomEditColumn('Verguetung', 'verguetung', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $validator = new DigitsValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('DigitsValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for beschreibung field
            //
            $editor = new TextEdit('beschreibung_edit');
            $editor->SetSize(80);
            $editor->SetMaxLength(150);
            $editColumn = new CustomEditColumn('Beschreibung', 'beschreibung', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for quelle_url field
            //
            $editor = new TextEdit('quelle_url_edit');
            $editor->SetSize(70);
            $editor->SetMaxLength(255);
            $editColumn = new CustomEditColumn('Quelle Url', 'quelle_url', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $validator = new UrlValidator(StringUtils::Format($this->GetLocalizerCaptions()->GetMessageString('UrlValidationMessage'), $this->RenderText($editColumn->GetCaption())));
            $editor->GetValidatorCollection()->AddValidator($validator);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for quelle field
            //
            $editor = new TextEdit('quelle_edit');
            $editor->SetSize(80);
            $editor->SetMaxLength(80);
            $editColumn = new CustomEditColumn('Quelle', 'quelle', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            
            //
            // Edit column for notizen field
            //
            $editor = new TextAreaEdit('notizen_edit', 50, 8);
            $editColumn = new CustomEditColumn('Notizen', 'notizen', $editor, $this->dataset);
            $editColumn->SetAllowSetToNull(true);
            $this->ApplyCommonColumnEditProperties($editColumn);
            $grid->AddInsertColumn($editColumn);
            if ($this->GetSecurityInfo()->HasAddGrant())
            {
                $grid->SetShowAddButton(true);
                $grid->SetShowInlineAddButton(false);
            }
            else
            {
                $grid->SetShowInlineAddButton(false);
                $grid->SetShowAddButton(false);
            }
        }
    
        protected function AddPrintColumns(Grid $grid)
        {
            //
            // View column for id field
            //
            $column = new TextViewColumn('id', 'Id', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for anzeige_name field
            //
            $column = new TextViewColumn('parlamentarier_id_anzeige_name', 'Parlamentarier', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'parlamentarier.php?operation=view&pk0=%parlamentarier_id%' , '_self');
            $column = new DivTagViewColumnDecorator($column);
            $column->Bold = true;
            $grid->AddPrintColumn($column);
            
            //
            // View column for anzeige_mixed field
            //
            $column = new TextViewColumn('organisation_id_anzeige_mixed', 'Organisation', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'organisation.php?operation=view&pk0=%organisation_id%' , '_self');
            $grid->AddPrintColumn($column);
            
            //
            // View column for art field
            //
            $column = new TextViewColumn('art', 'Art', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for funktion_im_gremium field
            //
            $column = new TextViewColumn('funktion_im_gremium', 'Funktion im Gremium', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for deklarationstyp field
            //
            $column = new TextViewColumn('deklarationstyp', 'Deklarationstyp', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for status field
            //
            $column = new TextViewColumn('status', 'Status', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for behoerden_vertreter field
            //
            $column = new TextViewColumn('behoerden_vertreter', 'Beh�rdenvertreter', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for von field
            //
            $column = new DateTimeViewColumn('von', 'Von', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for bis field
            //
            $column = new DateTimeViewColumn('bis', 'Bis', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for verguetung field
            //
            $column = new TextViewColumn('verguetung', 'Verguetung', $this->dataset);
            $column->SetOrderable(true);
            $column = new CurrencyFormatValueViewColumnDecorator($column, 0, '\'', '', $this->RenderText('Fr.'));
            $grid->AddPrintColumn($column);
            
            //
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_visa field
            //
            $column = new TextViewColumn('eingabe_abgeschlossen_visa', 'Eingabe Abgeschlossen Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_datum field
            //
            $column = new DateTimeViewColumn('eingabe_abgeschlossen_datum', 'Eingabe Abgeschlossen Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for kontrolliert_visa field
            //
            $column = new TextViewColumn('kontrolliert_visa', 'Kontrolliert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for kontrolliert_datum field
            //
            $column = new DateTimeViewColumn('kontrolliert_datum', 'Kontrolliert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for autorisiert_visa field
            //
            $column = new TextViewColumn('autorisiert_visa', 'Autorisiert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for autorisiert_datum field
            //
            $column = new DateTimeViewColumn('autorisiert_datum', 'Autorisiert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for freigabe_visa field
            //
            $column = new TextViewColumn('freigabe_visa', 'Freigabe Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for freigabe_datum field
            //
            $column = new DateTimeViewColumn('freigabe_datum', 'Freigabe Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for created_visa field
            //
            $column = new TextViewColumn('created_visa', 'Created Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for created_date field
            //
            $column = new DateTimeViewColumn('created_date', 'Created Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for updated_visa field
            //
            $column = new TextViewColumn('updated_visa', 'Updated Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
            
            //
            // View column for updated_date field
            //
            $column = new DateTimeViewColumn('updated_date', 'Updated Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddPrintColumn($column);
        }
    
        protected function AddExportColumns(Grid $grid)
        {
            //
            // View column for id field
            //
            $column = new TextViewColumn('id', 'Id', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for anzeige_name field
            //
            $column = new TextViewColumn('parlamentarier_id_anzeige_name', 'Parlamentarier', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'parlamentarier.php?operation=view&pk0=%parlamentarier_id%' , '_self');
            $column = new DivTagViewColumnDecorator($column);
            $column->Bold = true;
            $grid->AddExportColumn($column);
            
            //
            // View column for anzeige_mixed field
            //
            $column = new TextViewColumn('organisation_id_anzeige_mixed', 'Organisation', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, 'organisation.php?operation=view&pk0=%organisation_id%' , '_self');
            $grid->AddExportColumn($column);
            
            //
            // View column for art field
            //
            $column = new TextViewColumn('art', 'Art', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for funktion_im_gremium field
            //
            $column = new TextViewColumn('funktion_im_gremium', 'Funktion im Gremium', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for deklarationstyp field
            //
            $column = new TextViewColumn('deklarationstyp', 'Deklarationstyp', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for status field
            //
            $column = new TextViewColumn('status', 'Status', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for behoerden_vertreter field
            //
            $column = new TextViewColumn('behoerden_vertreter', 'Beh�rdenvertreter', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for von field
            //
            $column = new DateTimeViewColumn('von', 'Von', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for bis field
            //
            $column = new DateTimeViewColumn('bis', 'Bis', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for verguetung field
            //
            $column = new TextViewColumn('verguetung', 'Verguetung', $this->dataset);
            $column->SetOrderable(true);
            $column = new CurrencyFormatValueViewColumnDecorator($column, 0, '\'', '', $this->RenderText('Fr.'));
            $grid->AddExportColumn($column);
            
            //
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_visa field
            //
            $column = new TextViewColumn('eingabe_abgeschlossen_visa', 'Eingabe Abgeschlossen Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for eingabe_abgeschlossen_datum field
            //
            $column = new DateTimeViewColumn('eingabe_abgeschlossen_datum', 'Eingabe Abgeschlossen Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for kontrolliert_visa field
            //
            $column = new TextViewColumn('kontrolliert_visa', 'Kontrolliert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for kontrolliert_datum field
            //
            $column = new DateTimeViewColumn('kontrolliert_datum', 'Kontrolliert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for autorisiert_visa field
            //
            $column = new TextViewColumn('autorisiert_visa', 'Autorisiert Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for autorisiert_datum field
            //
            $column = new DateTimeViewColumn('autorisiert_datum', 'Autorisiert Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for freigabe_visa field
            //
            $column = new TextViewColumn('freigabe_visa', 'Freigabe Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for freigabe_datum field
            //
            $column = new DateTimeViewColumn('freigabe_datum', 'Freigabe Datum', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for created_visa field
            //
            $column = new TextViewColumn('created_visa', 'Created Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for created_date field
            //
            $column = new DateTimeViewColumn('created_date', 'Created Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for updated_visa field
            //
            $column = new TextViewColumn('updated_visa', 'Updated Visa', $this->dataset);
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
            
            //
            // View column for updated_date field
            //
            $column = new DateTimeViewColumn('updated_date', 'Updated Date', $this->dataset);
            $column->SetDateTimeFormat('d.m.Y H:i:s');
            $column->SetOrderable(true);
            $grid->AddExportColumn($column);
        }
    
        public function GetPageDirection()
        {
            return null;
        }
    
        protected function ApplyCommonColumnEditProperties(CustomEditColumn $column)
        {
            $column->SetDisplaySetToNullCheckBox(false);
            $column->SetDisplaySetToDefaultCheckBox(false);
    		$column->SetVariableContainer($this->GetColumnVariableContainer());
        }
    
        function GetCustomClientScript()
        {
            return ;
        }
        
        function GetOnPageLoadedClientScript()
        {
            return ;
        }
        public function interessenbindungGrid_OnGetCustomTemplate($part, $mode, &$result, &$params)
        {
        defaultOnGetCustomTemplate($this, $part, $mode, $result, $params);
        }
        public function interessenbindungGrid_OnCustomDrawRow($rowData, &$rowCellStyles, &$rowStyles)
        {
        customDrawRow('interessenbindung', $rowData, $rowCellStyles, $rowStyles);
        }
        function interessenbindungGrid_OnCustomRenderColumn($fieldName, $fieldData, $rowData, &$customText, &$handled)
        {
            customOnCustomRenderColumn('interessenbindung', $fieldName, $fieldData, $rowData, $customText, $handled);
        }
        function interessenbindungGrid_BeforeUpdateRecord($page, &$rowData, &$cancel, &$message, $tableName)
        {
            check_bis_date($page, $rowData, $cancel, $message, $tableName);
        }
        function interessenbindungGrid_BeforeInsertRecord($page, &$rowData, &$cancel, &$message, $tableName)
        {
            check_bis_date($page, $rowData, $cancel, $message, $tableName);
        }
        public function ShowEditButtonHandler(&$show)
        {
            if ($this->GetRecordPermission() != null)
                $show = $this->GetRecordPermission()->HasEditGrant($this->GetDataset());
        }
        public function ShowDeleteButtonHandler(&$show)
        {
            if ($this->GetRecordPermission() != null)
                $show = $this->GetRecordPermission()->HasDeleteGrant($this->GetDataset());
        }
        
        public function GetModalGridDeleteHandler() { return 'interessenbindung_modal_delete'; }
        protected function GetEnableModalGridDelete() { return true; }
        
        function partition_OnGetPartitions(&$partitions)
        {
            $tmp = array();
            $this->GetConnection()->ExecQueryToArray("
            SELECT DISTINCT
            left(p.nachname, 1) as first_letter
            FROM parlamentarier p
            ORDER BY first_letter", $tmp
            );
            
            foreach($tmp as $letter) {
              $partitions[$letter['first_letter']] = convert_ansi(strtoupper($letter['first_letter']));
            }
        }
        
        function partition_OnGetPartitionCondition($partitionKey, &$condition)
        {
            $condition = "interessenbindung.parlamentarier_id IN (SELECT `id` FROM `parlamentarier` s WHERE left(s.nachname, 1) = '$partitionKey')";
        }
    
        protected function CreateGrid()
        {
            $result = new Grid($this, $this->dataset, 'interessenbindungGrid');
            if ($this->GetSecurityInfo()->HasDeleteGrant())
               $result->SetAllowDeleteSelected(true);
            else
               $result->SetAllowDeleteSelected(false);   
            
            ApplyCommonPageSettings($this, $result);
            
            $result->SetUseImagesForActions(true);
            $result->SetDefaultOrdering('parlamentarier_id_anzeige_name', otAscending);
            $result->SetUseFixedHeader(true);
            $result->SetShowLineNumbers(true);
            
            $result->SetHighlightRowAtHover(false);
            $result->SetWidth('');
            $this->OnGetCustomTemplate->AddListener('interessenbindungGrid' . '_OnGetCustomTemplate', $this);
            $result->OnCustomDrawCell->AddListener('interessenbindungGrid' . '_OnCustomDrawRow', $this);
            $result->OnCustomRenderColumn->AddListener('interessenbindungGrid' . '_' . 'OnCustomRenderColumn', $this);
            $result->BeforeUpdateRecord->AddListener('interessenbindungGrid' . '_' . 'BeforeUpdateRecord', $this);
            $result->BeforeInsertRecord->AddListener('interessenbindungGrid' . '_' . 'BeforeInsertRecord', $this);
            $this->CreateGridSearchControl($result);
            $this->CreateGridAdvancedSearchControl($result);
            $this->AddOperationsColumns($result);
            $this->AddFieldColumns($result);
            $this->AddSingleRecordViewColumns($result);
            $this->AddEditColumns($result);
            $this->AddInsertColumns($result);
            $this->AddPrintColumns($result);
            $this->AddExportColumns($result);
    
            $this->SetShowPageList(true);
            $this->SetHidePageListByDefault(false);
            $this->SetExportToExcelAvailable(true);
            $this->SetExportToWordAvailable(true);
            $this->SetExportToXmlAvailable(true);
            $this->SetExportToCsvAvailable(true);
            $this->SetExportToPdfAvailable(false);
            $this->SetPrinterFriendlyAvailable(true);
            $this->SetSimpleSearchAvailable(true);
            $this->SetAdvancedSearchAvailable(true);
            $this->SetFilterRowAvailable(true);
            $this->SetVisualEffectsEnabled(true);
            $this->SetShowTopPageNavigator(true);
            $this->SetShowBottomPageNavigator(true);
    
            //
            // Http Handlers
            //
            //
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $column->SetReplaceLFByBR(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_beschreibung_handler_list', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, '%quelle_url%' , '');
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_quelle_url_handler_list', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_quelle_handler_list', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $column->SetReplaceLFByBR(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_notizen_handler_list', $column);
            GetApplication()->RegisterHTTPHandler($handler);//
            // View column for beschreibung field
            //
            $column = new TextViewColumn('beschreibung', 'Beschreibung', $this->dataset);
            $column->SetOrderable(true);
            $column->SetReplaceLFByBR(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_beschreibung_handler_view', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for quelle_url field
            //
            $column = new TextViewColumn('quelle_url', 'Quelle Url', $this->dataset);
            $column->SetOrderable(true);
            $column = new ExtendedHyperLinkColumnDecorator($column, $this->dataset, '%quelle_url%' , '');
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_quelle_url_handler_view', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for quelle field
            //
            $column = new TextViewColumn('quelle', 'Quelle', $this->dataset);
            $column->SetOrderable(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_quelle_handler_view', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            //
            // View column for notizen field
            //
            $column = new TextViewColumn('notizen', 'Notizen', $this->dataset);
            $column->SetOrderable(true);
            $column->SetReplaceLFByBR(true);
            $handler = new ShowTextBlobHandler($this->dataset, $this, 'interessenbindungGrid_notizen_handler_view', $column);
            GetApplication()->RegisterHTTPHandler($handler);
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_parlamentarier_simple`');
            $field = new StringField('anzeige_name');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('nachname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vorname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('zweiter_vorname');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('rat_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kanton_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('kommissionen');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('partei_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('parteifunktion');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('fraktion_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('fraktionsfunktion');
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_seit');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_bis');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratswechsel');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_von');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_bis');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('beruf_interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('zivilstand');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('anzahl_kinder');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('militaerischer_grad_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('geschlecht');
            $lookupDataset->AddField($field, false);
            $field = new DateField('geburtstag');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateierweiterung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname_voll');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_mime_type');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kleinbild');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('sitzplatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('email');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('parlament_biografie_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('linkedin_profil_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('xing_profil_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('facebook_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('arbeitssprache');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_firma');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_ort');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_1');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_2');
            $lookupDataset->AddField($field, false);
            $field = new StringField('erfasst');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisierung_verschickt_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('autorisierung_verschickt_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('von');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('bis');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('geburtstag_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_seit_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_bis_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('von_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('bis_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_name', GetOrderTypeAsSQL(otAscending));
            $lookupDataset->AddCustomCondition(EnvVariablesUtils::EvaluateVariableTemplate($this->GetColumnVariableContainer(), ''));
            $handler = new DynamicSearchHandler($lookupDataset, $this, 'edit_parlamentarier_id_anzeige_name_search', 'id', 'anzeige_name', null);
            GetApplication()->RegisterHTTPHandler($handler);
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_organisation_simple`');
            $field = new StringField('anzeige_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_mixed');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_it');
            $lookupDataset->AddField($field, false);
            $field = new StringField('uid');
            $lookupDataset->AddField($field, false);
            $field = new StringField('ort');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('land_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessenraum_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('rechtsform');
            $lookupDataset->AddField($field, false);
            $field = new StringField('typ');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vernehmlassung');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe2_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe3_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('branche_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new StringField('handelsregister_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_mixed', GetOrderTypeAsSQL(otAscending));
            $lookupDataset->AddCustomCondition(EnvVariablesUtils::EvaluateVariableTemplate($this->GetColumnVariableContainer(), ''));
            $handler = new DynamicSearchHandler($lookupDataset, $this, 'edit_organisation_id_anzeige_mixed_search', 'id', 'anzeige_mixed', null);
            GetApplication()->RegisterHTTPHandler($handler);
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_parlamentarier_simple`');
            $field = new StringField('anzeige_name');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('nachname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vorname');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('zweiter_vorname');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('rat_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kanton_id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('kommissionen');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('partei_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('parteifunktion');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('fraktion_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('fraktionsfunktion');
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_seit');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('im_rat_bis');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratswechsel');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_von');
            $lookupDataset->AddField($field, false);
            $field = new DateField('ratsunterbruch_bis');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beruf_fr');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('beruf_interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('zivilstand');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('anzahl_kinder');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('militaerischer_grad_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('geschlecht');
            $lookupDataset->AddField($field, false);
            $field = new DateField('geburtstag');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateierweiterung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_dateiname_voll');
            $lookupDataset->AddField($field, false);
            $field = new StringField('photo_mime_type');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kleinbild');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('sitzplatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('email');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('parlament_biografie_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('linkedin_profil_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('xing_profil_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('facebook_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('arbeitssprache');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_firma');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_ort');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_1');
            $lookupDataset->AddField($field, false);
            $field = new StringField('telephon_2');
            $lookupDataset->AddField($field, false);
            $field = new StringField('erfasst');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisierung_verschickt_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('autorisierung_verschickt_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('autorisiert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateField('autorisiert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('von');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateField('bis');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('geburtstag_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_seit_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('im_rat_bis_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('von_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('bis_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_name', GetOrderTypeAsSQL(otAscending));
            $lookupDataset->AddCustomCondition(EnvVariablesUtils::EvaluateVariableTemplate($this->GetColumnVariableContainer(), ''));
            $handler = new DynamicSearchHandler($lookupDataset, $this, 'insert_parlamentarier_id_anzeige_name_search', 'id', 'anzeige_name', null);
            GetApplication()->RegisterHTTPHandler($handler);
            $lookupDataset = new TableDataset(
                new MyPDOConnectionFactory(),
                GetConnectionOptions(),
                '`v_organisation_simple`');
            $field = new StringField('anzeige_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_mixed');
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('anzeige_name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('id');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_de');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('name_it');
            $lookupDataset->AddField($field, false);
            $field = new StringField('uid');
            $lookupDataset->AddField($field, false);
            $field = new StringField('ort');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('land_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessenraum_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('rechtsform');
            $lookupDataset->AddField($field, false);
            $field = new StringField('typ');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('vernehmlassung');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe2_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('interessengruppe3_id');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('branche_id');
            $lookupDataset->AddField($field, false);
            $field = new StringField('homepage');
            $lookupDataset->AddField($field, false);
            $field = new StringField('handelsregister_url');
            $lookupDataset->AddField($field, false);
            $field = new StringField('twitter_name');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung');
            $lookupDataset->AddField($field, false);
            $field = new StringField('beschreibung_fr');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_strasse');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_zusatz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('adresse_plz');
            $lookupDataset->AddField($field, false);
            $field = new StringField('notizen');
            $lookupDataset->AddField($field, false);
            $field = new StringField('eingabe_abgeschlossen_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('eingabe_abgeschlossen_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('kontrolliert_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('kontrolliert_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('freigabe_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('freigabe_datum');
            $lookupDataset->AddField($field, false);
            $field = new StringField('created_visa');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('created_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new StringField('updated_visa');
            $lookupDataset->AddField($field, false);
            $field = new DateTimeField('updated_date');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('created_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('updated_date_unix');
            $field->SetIsNotNull(true);
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('eingabe_abgeschlossen_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('kontrolliert_datum_unix');
            $lookupDataset->AddField($field, false);
            $field = new IntegerField('freigabe_datum_unix');
            $lookupDataset->AddField($field, false);
            $lookupDataset->SetOrderBy('anzeige_mixed', GetOrderTypeAsSQL(otAscending));
            $lookupDataset->AddCustomCondition(EnvVariablesUtils::EvaluateVariableTemplate($this->GetColumnVariableContainer(), ''));
            $handler = new DynamicSearchHandler($lookupDataset, $this, 'insert_organisation_id_anzeige_mixed_search', 'id', 'anzeige_mixed', null);
            GetApplication()->RegisterHTTPHandler($handler);
            return $result;
        }
        
        public function OpenAdvancedSearchByDefault()
        {
            return false;
        }
    
        protected function DoGetGridHeader()
        {
            return '' . $GLOBALS["edit_header_message"] /*afterburner*/  . '
    
    <div class="wiki-table-help">
    <p>Zuordnung der Interessenbindungen der <a class="wiki external" target="_blank" href="http://www.parlament.ch/d/organe-mitglieder/nationalrat/Documents/ra-nr-interessen.pdf" rel="_blank external nofollow">National</a>- und <a class="wiki external" target="_blank" href="http://www.parlament.ch/d/organe-mitglieder/staenderat/Documents/ra-sr-interessen.pdf" rel="_blank external nofollow">St�nder�te</a>.
    </p>
    
    <div class="clearfix rbox note"><div class="rbox-title"><img src="' . util_data_uri('img/icons/information.png') . '" alt="Hinweis" title="Hinweis" class="icon" width="16" height="16"><span>Hinweis</span></div><div class="rbox-data">Das Feld Interessenbindung.beschreibung soll den Bearbeitern einen Hinweis geben. Das Feld wird nicht automatisch ausgewertet.</div></div>
    </div>
    
    ' . $GLOBALS["edit_general_hint"] /*afterburner*/  . '';
        }
    }

    SetUpUserAuthorization(GetApplication());

    try
    {
        $Page = new interessenbindungPage("interessenbindung.php", "interessenbindung", GetCurrentUserGrantForDataSource("interessenbindung"), 'UTF-8');
        $Page->SetShortCaption('<span class="relation" title="Interessenbindungen der Parlamentarier">Intereressenbind. von NR/SR</span>');
        $Page->SetHeader(GetPagesHeader());
        $Page->SetFooter(GetPagesFooter());
        $Page->SetCaption('Interessenbindung');
        $Page->SetRecordPermission(GetCurrentUserRecordPermissionsForDataSource("interessenbindung"));
        GetApplication()->SetEnableLessRunTimeCompile(GetEnableLessFilesRunTimeCompilation());
        GetApplication()->SetCanUserChangeOwnPassword(
            !function_exists('CanUserChangeOwnPassword') || CanUserChangeOwnPassword());
        GetApplication()->SetMainPage($Page);
        before_render($Page); /*afterburner*/ 
        GetApplication()->Run();
    }
    catch(Exception $e)
    {
        ShowErrorPage($e->getMessage());
    }
