CREATE TABLE IF NOT EXISTS `ap_races` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id` bigint(20) NOT NULL DEFAULT '0',
  `race_number` int(11) DEFAULT NULL,
  `election_date` datetime DEFAULT NULL,
  `state_postal` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county_number` int(11) DEFAULT NULL,
  `fips_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office_id` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type_id` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `seat_number` int(11) DEFAULT NULL,
  `office_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `seat_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type_party` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_winners` int(11) DEFAULT NULL,
  `number_in_runoff` int(11) DEFAULT NULL,
  `precincts_reporting` int(11) DEFAULT NULL,
  `total_precincts` int(11) DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `stage_ap_races` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_county_id` bigint(20) DEFAULT NULL,
  `race_number` int(11) DEFAULT NULL,
  `election_date` datetime DEFAULT NULL,
  `state_postal` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county_number` int(11) DEFAULT NULL,
  `fips_code` int(11) DEFAULT NULL,
  `county_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office_id` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type_id` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `seat_number` int(11) DEFAULT NULL,
  `office_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `seat_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type_party` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_winners` int(11) DEFAULT NULL,
  `number_in_runoff` int(11) DEFAULT NULL,
  `precincts_reporting` int(11) DEFAULT NULL,
  `total_precincts` int(11) DEFAULT NULL,
  `ap_race_id` bigint(20) DEFAULT NULL,
  KEY `index_stage_ap_races_on_ap_race_id` (`ap_race_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `ap_results` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `ap_race_id` bigint(20) NOT NULL DEFAULT '0',
  `ap_candidate_id` bigint(20) NOT NULL DEFAULT '0',
  `party` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `incumbent` tinyint(1) DEFAULT NULL,
  `vote_count` int(11) DEFAULT NULL,
  `winner` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `natl_order` int(11) DEFAULT NULL,
  `winner_override` int(11) DEFAULT NULL,
  PRIMARY KEY (`ap_candidate_id`,`ap_race_id`),
  KEY `index_ap_results_on_ap_race_id` (`ap_race_id`),
  KEY `index_ap_results_on_ap_candidate_id` (`ap_candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `stage_ap_results` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `race_county_id` bigint(20) DEFAULT NULL,
  `candidate_id` bigint(20) DEFAULT NULL,
  `party` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `incumbent` tinyint(1) DEFAULT NULL,
  `vote_count` int(11) DEFAULT NULL,
  `winner` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `natl_order` int(11) DEFAULT NULL,
  KEY `index_stage_ap_results_on_race_county_id` (`race_county_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `ap_candidates` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id` bigint(20) NOT NULL DEFAULT '0',
  `candidate_number` int(11) DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `junior` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_junior` tinyint(1) DEFAULT NULL,
  `politician_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `stage_ap_candidates` (
  `test_flag` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `candidate_id` bigint(20) DEFAULT NULL,
  `candidate_number` int(11) DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `junior` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_junior` tinyint(1) DEFAULT NULL,
  `politician_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
