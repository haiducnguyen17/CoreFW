*** Settings ***
Resource    ../../../../../resources/bug_report.robot
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library   ../../../../../py_sources/logigear/setup.py               
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/spaces/AdmGeomapOptionsPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py

Default Tags    Spaces

Suite Setup    Run Keywords    Open SM Login Page
...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
...    AND    Select Main Menu    ${Administration}/${Spaces}
...    AND    Go To Geomap Options
...    AND    Fill Custom Geomap Map View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
...    AND    Set Custom Geomap Server Map View    ${False}
...    AND    Fill Custom Geomap Satellite View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY} 
...    AND    Set Custom Geomap Server Satellite View    ${False}    ${True}    ${True}   
...    AND    Select Main Menu    ${Site Manager}

Suite Teardown    Close Browser

*** Variables ***
${SCALE_METRIC_LEVEL_1}    5000 km
${SCALE_IMPERIAL_LEVEL_1}    2000 mi
${URL_TEMPLATE_1}    https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}
${URL_TEMPLATE_2}    https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}
${TEXT1}	Google
${URL_LINK_1}	https://www.google.com/maps
${TEXT2}	Google guidelines
${URL_LINK_2}	https://www.google.com/permissions/geoguidelines/

*** Test Cases ***
SM-30286-01_Verify that the new scale indicator is added into GeoMap with Map View
    
    [Tags]    SM-30286

    ${scale_list_metric}    create list     2000 km    1000 km    500 km    200 km    100 km    50 km    20 km    10 km    5 km    5 km    2 km    1000 m    500 m    200 m    100 m    50 m    20 m    10 m    5 m    5 m    2 m
    ${scale_list_imperial}    create list    1000 mi    500 mi    200 mi    100 mi    50 mi    50 mi    20 mi    10 mi    5 mi    2 mi    5000 ft    2000 ft    1000 ft    500 ft    500 ft    200 ft    100 ft    50 ft    20 ft    10 ft    5 ft
    
    # 1. On Site Manager, notice Site is highlighted
	# 2. Click on Spaces icon to Switch to Spaces view
	Go To Another View On Site Manager    ${Spaces}
	Click Tree Node On Site Manager    ${SITE_NODE}
	Click Zoom Extent Button
	
	# 3. Notice GeoMap displays with MapView
	Switch Geomap View    Map
	Check Map Div Display
	Switch Scale Indicator Unit    km
	
	# 4. Observer the result
	# VP:*Step 4: There is a new scale indicator on the bottom-right of the image
	Check Scale Indicator Displays On Geo Map
	
	# 5. Click Zoom in button and observe the scale indicator
	Zoom Map    in    1
	Check Scale Indicator Value    ${scale_list_metric}[1]
	
	# 6. Click Zoom out button and observe the scale indicator
	Zoom Map    out    1
	Check Scale Indicator Value    ${scale_list_metric}[0]
	
	# 7. Click Zoom Extents button then Switch between decimal and imperial by clicking the scale indicator in many zoom level (22 levels)
	
	# 8. observe the result
	Click Zoom Extent Button
	Zoom Map    out    1
	Check Scale Indicator Value    ${SCALE_METRIC_LEVEL_1}
	
    :FOR    ${i}    IN RANGE    len(${scale_list_metric})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_metric}[${i}]
    
    Click Zoom Extent Button
    Switch Scale Indicator Unit    mi
    Zoom Map    out    1
    Check Scale Indicator Value    ${SCALE_IMPERIAL_LEVEL_1}
    
    :FOR    ${i}    IN RANGE    len(${scale_list_imperial})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_imperial}[${i}]

SM-30286-02_Verify that the new scale indicator is added into GeoMap with Satellite View
    
    [Tags]    SM-30286

    ${scale_list_metric}    Create List     2000 km    1000 km    500 km    200 km    100 km    50 km    20 km    10 km    5 km    5 km    2 km    1000 m    500 m    200 m    100 m    50 m    20 m    10 m    5 m    5 m    2 m
    ${scale_list_imperial}    create list    1000 mi    500 mi    200 mi    100 mi    50 mi    50 mi    20 mi    10 mi    5 mi    2 mi    5000 ft    2000 ft    1000 ft    500 ft    500 ft    200 ft    100 ft    50 ft    20 ft    10 ft    5 ft
    
    # 1. On Site Manager, notice Site is highlighted
	# 2. Click on Spaces icon to Switch to Spaces view
	Go To Another View On Site Manager    ${Spaces}
	Click Tree Node On Site Manager    ${SITE_NODE}
	
	# 3. On GeoMap Switch to Satellite View
	Switch Geomap View    Satellite
	Click Zoom Extent Button
	Check Map Div Display
    Switch Scale Indicator Unit    km
    
	# 4. Observer the result
	Check Scale Indicator Displays On Geo Map
	
	# 5. Click Zoom in button and observe the scale indicator
	Zoom Map    in    1
	Check Scale Indicator Value    ${scale_list_metric}[1]
	
	# 6. Click Zoom out button and observe the scale indicator
	Zoom Map    out    1
	Check Scale Indicator Value    ${scale_list_metric}[0]
	
	# 7. Click Zoom Extents button then Switch between decimal and imperial by clicking the scale indicator in many zoom level (23 levels)
	# 8. observe the result
	
	Click Zoom Extent Button
	Zoom Map    out    1
	Check Scale Indicator Value    ${SCALE_METRIC_LEVEL_1}
	
    :FOR    ${i}    IN RANGE    len(${scale_list_metric})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_metric}[${i}]
    
    Click Zoom Extent Button
    Switch Scale Indicator Unit    mi
    Zoom Map    out    1
    Check Scale Indicator Value    ${SCALE_IMPERIAL_LEVEL_1}
    
    :FOR    ${i}    IN RANGE    len(${scale_list_imperial})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_imperial}[${i}] 

SM-30286-03_Verify that the new scale indicator still work correctly when user uses Custom GeoMap Server for MapView
    
    [Tags]    SM-30286
    
    [Teardown]    Run Keywords       Select Main Menu    ${Administration}
    ...    AND    Go To Geomap Options
    ...    AND    Fill Custom Geomap Map View    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    AND    Set Custom Geomap Server Map View    ${False}    ${True}    ${True}
   
    ${scale_list_metric}    Create List     2000 km    1000 km    500 km    200 km    100 km    50 km    20 km    10 km    5 km    5 km    2 km    1000 m    500 m    200 m    100 m    50 m    20 m    10 m    5 m    5 m    2 m
    ${scale_list_imperial}    create list    1000 mi    500 mi    200 mi    100 mi    50 mi    50 mi    20 mi    10 mi    5 mi    2 mi    5000 ft    2000 ft    1000 ft    500 ft    500 ft    200 ft    100 ft    50 ft    20 ft    10 ft    5 ft
    
	# 1. Go to Administration -> GeoMap Options
	# 2. Check on checkboxes: "Use Custom GeoMap Server - Map View"
	# 3. Enter values for Map view as below:
	# _URL Template: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}"
	# _ Maximum Zoom Level: 23
	# _ Attribution Link:
	# + Text: google
	# + URL Link: google.com
	# 4. Click Save button
	Select Main Menu    ${Administration}
    Go To Geomap Options
    Set Custom Geomap Server Map View    ${True}
    Fill Custom Geomap Map View    ${URL_TEMPLATE_1}    23    ${TEXT1}    ${URL_LINK_1}    ${TEXT2}    ${URL_LINK_2}    save=${True}    confirm=${True}
	
	# 5. Return to Site Manager
	Select Main Menu    ${Site Manager}

	# 6. On Site Manager, notice Site is highlighted
	# 7. Click on Spaces icon to Switch to Spaces view
	Go To Another View On Site Manager    ${Spaces}
	Click Tree Node On Site Manager    ${SITE_NODE}
	Click Zoom Extent Button
	
	# 8. Notice GeoMap displays with MapView
	Switch Geomap View    Map
	Check Map Div Display
	Switch Scale Indicator Unit    km
	
	# 9. Observer the result
	Check Scale Indicator Displays On Geo Map
	
	# 10. Click Zoom in button and observe the scale indicator
	Zoom Map    in    1
	Check Scale Indicator Value    ${scale_list_metric}[1]
	
	# 11. Click Zoom out button and observe the scale indicator
	Zoom Map    out    1
	Check Scale Indicator Value    ${scale_list_metric}[0]
	
	# 12. Click Zoom Extents button then Switch between decimal and imperial by clicking the scale indicator in many zoom level
	# 13. observe the result
	Click Zoom Extent Button
	Zoom Map    out    1
	Check Scale Indicator Value    ${SCALE_METRIC_LEVEL_1}
	
    :FOR    ${i}    IN RANGE    len(${scale_list_metric})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_metric}[${i}]
    
    Click Zoom Extent Button
    Switch Scale Indicator Unit    mi
    Zoom Map    out    1
    Check Scale Indicator Value    ${SCALE_IMPERIAL_LEVEL_1}
    
    :FOR    ${i}    IN RANGE    len(${scale_list_imperial})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_imperial}[${i}]
     
SM-30286-04_Verify that the new scale indicator is added into GeoMap with Satellite View
      
    [Tags]    SM-30286
    
    [Teardown]    Run Keywords       Select Main Menu    ${Administration}
    ...    AND    Go To Geomap Options
    ...    AND    Fill Custom Geomap Satellite View    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    AND    Set Custom Geomap Server Satellite View    ${False}    ${True}    ${True}
    
    ${scale_list_metric}    Create List     2000 km    1000 km    500 km    200 km    100 km    50 km    20 km    10 km    5 km    5 km    2 km    1000 m    500 m    200 m    100 m    50 m    20 m    10 m    5 m    5 m    2 m
    ${scale_list_imperial}    create list    1000 mi    500 mi    200 mi    100 mi    50 mi    50 mi    20 mi    10 mi    5 mi    2 mi    5000 ft    2000 ft    1000 ft    500 ft    500 ft    200 ft    100 ft    50 ft    20 ft    10 ft    5 ft
    
	# 1. Go to Administration -> GeoMap Options
	# 2. Check on checkboxes: "Use Custom GeoMap Server - Map View"
	# 3. Enter values for Map view as below:
	# _URL Template: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}"
	# _ Maximum Zoom Level: 23
	# _ Attribution Link:
	# + Text: google
	# + URL Link: google.com
	# 4. Click Save button
	Select Main Menu    ${Administration}
    Go To Geomap Options
    Set Custom Geomap Server Satellite View    ${True}
    Fill Custom Geomap Satellite View    ${URL_TEMPLATE_2}    23    ${TEXT1}    ${URL_LINK_1}    ${TEXT2}    ${URL_LINK_2}    save=${True}    confirm=${True}
	
	# 5. Return to Site Manager
	Select Main Menu    ${Site Manager}

	# 6. On Site Manager, notice Site is highlighted
	# 7. Click on Spaces icon to Switch to Spaces view
	Go To Another View On Site Manager    ${Spaces}
	Click Tree Node On Site Manager    ${SITE_NODE}
    Check Map Div Display
    
	# 8.  on GeoMap Switch to Satellite View
	Switch Geomap View    Satellite
	Click Zoom Extent Button
	Check Map Div Display
	Switch Scale Indicator Unit    km
	
	# 9. Observer the result
	Check Scale Indicator Displays On Geo Map
	
	# 10. Click Zoom in button and observe the scale indicator
	Zoom Map    in    1
	Check Scale Indicator Value    ${scale_list_metric}[1]
	
	# 11. Click Zoom out button and observe the scale indicator
	Zoom Map    out    1
	Check Scale Indicator Value    ${scale_list_metric}[0]
	
	# 12. Click Zoom Extents button then Switch between decimal and imperial by clicking the scale indicator in many zoom level
	# 13. observe the result
	Click Zoom Extent Button
	Zoom Map    out    1
	Check Scale Indicator Value    ${SCALE_METRIC_LEVEL_1}
	
    :FOR    ${i}    IN RANGE    len(${scale_list_metric})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_metric}[${i}]
    
    Click Zoom Extent Button
    Switch Scale Indicator Unit    mi
    Zoom Map    out    1
    Check Scale Indicator Value    ${SCALE_IMPERIAL_LEVEL_1}
    
    :FOR    ${i}    IN RANGE    len(${scale_list_imperial})
    \    Zoom Map    in    1
    \    Check Scale Indicator Value    ${scale_list_imperial}[${i}]  