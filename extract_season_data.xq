<season_data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation= "season_data.xsd">
    <season>
        <name>
            {data(doc("season_info.xml")//season/@name)}
        </name>
        <competition>
            {data(doc("season_info.xml")//season/competition/@name)}
        </competition>
        <date>
            <start>
                {data(doc("season_info.xml")//season/@start_date)}
            </start>
            <end>
                {data(doc("season_info.xml")//season/@end_date)}
            </end>
            <year>
                {data(doc("season_info.xml")//season/@year)}
            </year>
        </date>
    </season>
    <stages>
    {
        for $current_stage in doc("season_info.xml")//stages/stage
            order by $current_stage/@order
            return
            <stage phase= "{data($current_stage/@phase)}"  start_date="{data($current_stage/@start_date)}" end_date="{data($current_stage/@end_date)}">
                <groups>
                {
                    for $current_group in doc("season_info.xml")//stages/$current_stage

                    return
                    <group>
                    {
                        for $current_competitor in $current_group//competitor
                        return
                        <competitor>
                            <name>
                                {data($current_competitor/@name)}
                            </name>
                            <country>
                                {data($current_competitor/@country)}
                            </country>
                        </competitor>
                    }
                    {
                        for $current_summary in doc("season_summaries.xml")//summary[./sport_event//groups/group/@id = $current_stage/@id]

                        return
                        <event start_time="{data($current_summary/sport_event/@start_time)}">
                            <status>
                                {data($current_summary/sport_event_status/@match_status)}
                            </status>
                            <local>
                                <name>
                                    {data($current_summary//competitor[@qualifier = "home"]/@name)}

                                </name>
                                <score>
                                    {data($current_summary/sport_event_status/@home_score)}
                                </score>
                            </local>
                            <visitor>
                                <name>
                                    {data($current_summary//competitor[@qualifier = "away"]/@name)}

                                </name>
                                <score>
                                    {data($current_summary/sport_event_status/@away_score)}

                                </score>
                            </visitor>
                        </event>
                    }


                    </group>

                }
                </groups>
            </stage>
    }
    </stages>

</season_data>
