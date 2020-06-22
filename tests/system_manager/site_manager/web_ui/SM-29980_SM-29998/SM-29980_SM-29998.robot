*** Settings ***
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}             
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py     

Default Tags    Web UI
Force Tags    SM-29980_SM-29998

*** Variables ***
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 ${RACK_NAME}
${SWITCH_NAME}    Switch 01
${SERVER_NAME}    Server 01
${PANEL_NAME_01}	Panel 01
${PANEL_NAME_02}	Panel 02

*** Test Cases ***
SM-29998_01_Verify the new image, tooltip for MPO12 to 4xLC EB, MPO12 to 6xLC EB on cabling (patching/ f2b cabling) is displayed
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_01
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    [Tags]    Sanity

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}

    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add MPO Panel 01, LC Panel 02 with some port to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_01}    portType=${MPO}	
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_02}    portType=${LC}
    
    # 4. Open cabling window for Panel 01/01 and observe the result
    Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
    Check Mpo Connection Type Information On Cabling Window    ${MPO12}    ${Mpo12_4xLC}    
    Check Mpo Connection Type Information On Cabling Window    ${MPO12}    ${Mpo12_6xLC}    title=${Method B}        
    Check Mpo Connection Type Information On Cabling Window    ${MPO12}    ${Mpo12_6xLC_EB}    title=${Method B Enhanced}
    Close Cabling Window
   
    # 5. Open patching window for Panel 01/01 and observe the result
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
    Check Mpo Connection Type Information On Patching Window    ${MPO12}    ${Mpo12_4xLC}
    Check Mpo Connection Type Information On Patching Window    ${MPO12}    ${Mpo12_6xLC}    title=${Method B}
    Check Mpo Connection Type Information On Patching Window    ${MPO12}    ${Mpo12_6xLC_EB}    title=${Method B Enhanced}
    Close Patching Window
    
    # 6. Open f2b cabling window for Panel 02/01 and observe the result
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${01}
    Check Mpo Connection Type Information On Front To Back Cabling Window    ${MPO12}    ${Mpo12_4xLC_Symmetry}
    Check Mpo Connection Type Information On Front To Back Cabling Window    ${MPO12}    ${Mpo12_6xLC_Symmetry}    title=${Method B} 
    Check Mpo Connection Type Information On Front To Back Cabling Window    ${MPO12}    ${Mpo12_6xLC_EB_Symmetry}    title=${Method B Enhanced} 
    Close Front To Back Cabling Window
    
(Bulk_SM-29998-02-05)_Verify the icon a new image is displayed correctly for MPO12 Panel Cabled to LCPanel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_02_05
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${pair_list2}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add MPO12 Panel 01 and LC Panel 02 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}   
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_01}    portType=${MPO}
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_02}    portType=${LC}      
        
    # SM-29998-02: Verify the icon a new image is for MPO12 Panel 4xLC cabled to LCPanel
    # 4. Create cabling from Panel 01/ 01 to Panel 02 /  01-04 with 4xLC
    # 5. Trace Panel 01 / 01, Panel 02 / 01-04
    # VP: The new image is displayed 
    Open Cabling Window     ${tree_node_rack}/${PANEL_NAME_01}    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_01}/${01}    cableTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    mpoType=Mpo12_4xLC    portsTo=${01},${02},${03},${04}    
    Close Cabling Window
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledAvailable}    

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4X_LC_BACK_BACK_CABLING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    4        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_BACK_BACK_CABLING}
    \    Close Trace Window       
       
    # SM-29998-05: Verify the icon a new image is for MPO12 Panel 6xLC EB cabled to LCPanel
    # 4. Create cabling from Panel 01/ 01 to Panel 02 /  01-06 with 6xLC EB
    # 5. Trace Panel 01 / 01, Panel 02 / 01-06 
    # VP: The new image is displayed    
    Open Cabling Window     ${tree_node_rack}/${PANEL_NAME_01}    ${02}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_01}/${02}    cableTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    mpoType=${Mpo12_6xLC_EB}    portsTo=${05},${06},${07},${08},${09},${10}    
    Close Cabling Window
    Wait For Port Icon Exist On Content Table    ${02}    ${PortMPOPanelCabledAvailable}    

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${02}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    4    10        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
    \    Close Trace Window  

(Bulk_SM-29998-09-11)_Verify the icon a new image is displayed correctly for LCPanel Front To Back Cabling MPO12 Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_09_11
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${pair_list2}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add MPO12 Panel 01 and LC Panel 02 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}   
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_01}    portType=${MPO}
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_02}    portType=${LC}
    
    # SM-29998-09: Verify the icon a new image is for LC Panel front to back cabling 4xLC to MPO Panel
    # 4. Create front to back cabling from Panel 02 /  01-04 to Panel 01/ 01 with 4xLC
    # 5. Trace Panel 01 / 01, Panel 02 / 01-04
    # VP: The new image is displayed 
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${11}    
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_02}    cabTo=${tree_node_rack}/${PANEL_NAME_01}
    ...    portsFrom=${11},${12},${13},${14}    portsTo=${03}    mpoType=${Mpo12_4xLC_Symmetry}    mpoTab=${MPO12}
    ...    mpoBranches=${1-1},${2-2},${3-3},${4-4}  
    Close Front To Back Cabling Window    
    Wait For Port Icon Exist On Content Table    ${11}    ${PortFDUncabledInUse}

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${03}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    10    14        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}
    \    Close Trace Window 

    # SM-29998-11: Verify the icon a new image is for LC Panel front to back cabling 6xLC EB to MPO12 Panel
    # 4. Create cabling from Panel 02 /  01-06 to Panel 01/ 01 with 6xLC EB
    # 5. Trace Panel 01 / 01, Panel 02 / 01-06 
    # VP: The new image is displayed
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${15}    
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_02}    cabTo=${tree_node_rack}/${PANEL_NAME_01}
    ...    portsFrom=${15},${16},${17},${18},${19},${20}    portsTo=${04}    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6} 
    Close Front To Back Cabling Window
    Wait For Port Icon Exist On Content Table    ${15}    ${PortFDUncabledInUse}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${04}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    14    20        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Close Trace Window 
    
(Bulk_SM-29998-03-06)_Verify the icon a new image is displayed correctly for DM08 connected to LCPanel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_03_06
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    

    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${tree_node_panel_01_module_type}    Set Variable    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})
    ${pair_list1}    Create List    ${MPO2-01}    ${MPO2-02}    ${MPO2-03}    ${MPO2-04}
    ${pair_list2}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add DM08 Panel 01 and LC Panel 02 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}       
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_01}    ${Module 1A},${True},${LC 12 Port},${DM08}
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_02}    portType=${LC}
    
    # SM-29998-03: Verify the icon a new image is for DM08 4xLC cabled to LCPanel
    # 4. Create cabling from Panel 01 / 01 to Panel 02 /  01-04 with 4xLC
    # 5. Trace Panel 01 / 01, Panel 02 / 01-04 
    # VP: The new image is displayed 
    Open Cabling Window     ${tree_node_panel_01_module_type}    ${MPO1-01}
    Create Cabling    cableFrom=${tree_node_panel_01_module_type}/${MPO} ${01}    cableTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    mpoType=Mpo12_4xLC    portsTo=${01},${02},${03},${04}    
    Close Cabling Window
            
    :FOR    ${i}    IN RANGE    0    len(${pair_list2})  
    \    Open Trace Window    ${tree_node_panel_01_module_type}    ${pair_list2}[${i}] 	         
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4X_LC_BACK_BACK_CABLING}
    \    Close Trace Window

    :FOR    ${i}    IN RANGE    0    4        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_BACK_BACK_CABLING}
    \    Close Trace Window       
       
    # SM-29998-06: Verify the icon a new image is for DM08 6xLC EB cabled to LCPanel
    # 4. Create cabling from Panel 01 / 01 to Panel 02 /  01-06 with 6xLC EB
    # 5. Trace Panel 01 / 01, Panel 02 / 01-06 
    # VP: The new image is displayed    
    Open Cabling Window     ${tree_node_panel_01_module_type}    ${MPO2-01}
    Create Cabling    cableFrom=${tree_node_panel_01_module_type}/${MPO} ${02}    cableTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    mpoType=${Mpo12_6xLC_EB}    portsTo=${05},${06},${07},${08},${09},${10}    
    Close Cabling Window    

    :FOR    ${i}    IN RANGE    0    len(${pair_list1})  
    \    Report Bug    SM-30084
    \    Open Trace Window    ${tree_node_panel_01_module_type}    ${pair_list1}[${i}] 	         
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    \    Close Trace Window
    
    :FOR    ${i}    IN RANGE    4    10        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
    \    Close Trace Window        

(Bulk_SM-29998-10-12)_Verify the icon a new image is displayed correctly for DM08 connected to LCPanel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_10_12
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    

    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${tree_node_panel_01_module_type}    Set Variable    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})
    ${pair_list1}    Create List    ${MPO2-01}    ${MPO2-02}    ${MPO2-03}    ${MPO2-04}    
    ${pair_list2}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add DM08 Panel 01 and LC Panel 02 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}       
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_01}    ${Module 1A},${True},${LC 12 Port},${DM08}
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_02}    portType=${LC}
    
    # SM-29998-10: Verify the icon a new image is for LCPanel front to back cabling 4xLC to DM08
    # 4. Create front to back cabling from Panel 02 /  01-04 to Panel 01/ 01 with 4xLC
    # 5. Trace Panel 01 / 01, Panel 02 / 01-04
    # VP: The new image is displayed 
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${01}    
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_02}    cabTo=${tree_node_panel_01_module_type}
    ...    portsFrom=${01},${02},${03},${04}    portsTo=${MPO} ${01}    mpoType=${Mpo12_4xLC_Symmetry}    mpoTab=${MPO12}
    ...    mpoBranches=${1-1},${2-2},${3-3},${4-4}  
    Close Front To Back Cabling Window    
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}    
        
    :FOR    ${i}    IN RANGE    0    len(${pair_list2})    	         
	\    Open Trace Window    ${tree_node_panel_01_module_type}    ${pair_list2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
    \    Close Trace Window

    :FOR    ${i}    IN RANGE    0    4        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}
    \    Close Trace Window 

    # SM-29998-12: Verify the icon a new image is for  LC Panel front to back cabling 6xLC EB to DM08
    # 4. Create cabling from Panel 02 /  01-06 to Panel 01/ 01 with 6xLC EB
    # 5. Trace Panel 01 / 01, Panel 02 / 01-06 
    # VP: The new image is displayed
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${05}    
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_02}    cabTo=${tree_node_panel_01_module_type}
    ...    portsFrom=${05},${06},${07},${08},${09},${10}    portsTo=${MPO} ${02}    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6} 
    Close Front To Back Cabling Window
    Wait For Port Icon Exist On Content Table    ${05}    ${PortFDUncabledInUse}
        
    :FOR    ${i}    IN RANGE    0    len(${pair_list1})    	         
	\    Open Trace Window    ${tree_node_panel_01_module_type}    ${pair_list1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
    \    Close Trace Window
    
    :FOR    ${i}    IN RANGE    4    10        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Close Trace Window 

(Bulk_SM-29998-08-13)_Verify the icon a new image is displayed correctly for DM12 connected to LCPanel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_08_13
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
  
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${tree_node_panel_01_module_type}    Set Variable    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM12})
    ${pair_list1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}      
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}    ${11}    ${12}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add DM08 Panel 01 and LC Panel 02 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}       
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_01}    ${Module 1A},${True},${LC 12 Port},${DM12}
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_02}    portType=${LC}
    
    # SM-29998-13: Verify the icon a new image is for  LC Panel front to back cabling 6xLC EB to DM12
    # 4. Create cabling from Panel 02 /  01-06 to Panel 01/ 01 with 6xLC EB
    # 5. Trace Panel 01 / 01, Panel 02 / 01-06 
    # VP: The new image is displayed
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_02}    ${07}    
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_02}    cabTo=${tree_node_panel_01_module_type}
    ...    portsFrom=${07},${08},${09},${10},${11},${12}    portsTo=${MPO} ${02}    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6} 
    Close Front To Back Cabling Window
    Wait For Port Icon Exist On Content Table    ${07}    ${PortFDUncabledInUse}
    
    :FOR    ${i}    IN RANGE    6    12        
	\    Open Trace Window    ${tree_node_panel_01_module_type}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
    \    Close Trace Window 
    
    :FOR    ${i}    IN RANGE    6    12        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Close Trace Window 

    # SM-29998-08: Verify the icon a new image is for DM12 6xLC EB cabled to LCPanel
    # 4. Create front to back cabling from Panel 02 /  01-04 to Panel 01/ 01 with 4xLC
    # 5. Trace Panel 01 / 01, Panel 02 / 01-04
    # VP: The new image is displayed 
    Open Cabling Window     ${tree_node_panel_01_module_type}    ${01}
    Create Cabling    cableFrom=${tree_node_panel_01_module_type}/${MPO} ${01}    cableTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    mpoType=${Mpo12_6xLC_EB}    portsTo=${01},${02},${03},${04},${05},${06}    
    Close Cabling Window
    Wait For Port Icon Exist On Content Table    ${05}    ${PortFDCabledInUse}
    
    Open Trace Window    ${tree_node_panel_01_module_type}    ${01}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    0    6        
    \    Report Bug    SM-30084
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
    \    Close Trace Window

(Bulk_SM-29998-04-07)_Verify the icon a new image is displayed correctly for MPO12 Panel connected to LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM_29998_04_07
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${pair_list2}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}    ${07}    ${08}    ${09}    ${10}

    # 1. Launch and log into SM Web
    # 2. Add Building / Floor / Room / Rack
    # 3. Add MPO 12 Panel 01 and LC Switch 01 to Rack
    Add Building    ${SITE_NODE}   	${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}   
    Add Generic Panel    treeNode=${tree_node_rack}    name=${PANEL_NAME_01}    portType=${MPO}
    
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME}    name=${01}    portType=${LC}    quantity=10    

    # SM-29998-04: Verify the icon a new image is for MPO12 Panel 4xLC cabled to LC Switch
    # 4. Create cabling from Panel 01/ 01 to Switch 01 /  01-04 with 4xLC
    # 5. Trace Panel 01 / 01, Switch 01 / 01-04 
    # VP: The new image is displayed 
    Open Cabling Window     ${tree_node_rack}/${PANEL_NAME_01}    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_01}/${01}    cableTo=${tree_node_rack}/${SWITCH_NAME}
    ...    mpoType=Mpo12_4xLC    portsTo=${01},${02},${03},${04}    
    Close Cabling Window
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledAvailable}    
    
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    4        
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}
    \    Close Trace Window       
       
    # SM-29998-07: Verify the icon a new image is for MPO12 Panel 6xLC EB cabled to LC Switch
    # 4. Create cabling from Panel 01/ 01 to Switch 01 /  01-06 with 6xLC EB
    # 5. Trace Panel 01 / 01, Switch 01 / 01-06 
    # VP: The new image is displayed    
    Open Cabling Window     ${tree_node_rack}/${PANEL_NAME_01}    ${02}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_01}/${02}    cableTo=${tree_node_rack}/${SWITCH_NAME}
    ...    mpoType=${Mpo12_6xLC_EB}    portsTo=${05},${06},${07},${08},${09},${10}    
    Close Cabling Window
    Wait For Port Icon Exist On Content Table    ${02}    ${PortMPOServiceCabledAvailable}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${02}    
    :FOR    ${i}    IN RANGE    0    len(${pair_list1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    4    10        
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Close Trace Window      

SM-29998_14_Verify the icon a new image is for MPO12 Panel 4xLC patched to LCPanel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_14
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}
    ${tc_wo_name}    Set Variable    WO_SM29998_14

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Panel 01 and LC Panel 02 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_01}    portType=${MPO}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_02}    portType=${LC}
	
    # 4. Open Patching window and create patching from Panel 01 / 01 to Panel 02 /  01-04 with 4xLC
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_01}    patchTo=${tree_node_rack}/${PANEL_NAME_02}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    	
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Patching    ${pair_list}[${i}]
    \    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}    
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}    

	# 7. Trace Panel 01 / 01, Panel 02 / 01-04 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1   connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse} 

	# 9. Trace Panel 01 / 01, Panel 02 / 01-04
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

SM-29998_15_Verify the icon a new image is for MPO12 Panel 4xLC patched to LCPanel (Alpha)
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_15
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}
    ${tc_wo_name}    Set Variable    WO_SM29998_15

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Panel 01 and LC (Alpha) Panel 02 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_01}    portType=${MPO}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_02}    ${Module 1A},True,${LC 12 Port},${Alpha}
	
    # 4. Open Patching window and create patching from Panel 01 / 01 to Panel 02 /  01-04 with 4xLC
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_01}    01
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_01}    patchTo=${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${Alpha})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    	
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Patching    ${pair_list}[${i}]
    \    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}    
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}

	# 7. Trace Panel 01 / 01, Panel 02 / 01-04 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${Alpha})    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1   connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}

	# 9. Trace Panel 01 / 01, Panel 02 / 01-04
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${Alpha})    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

SM-29998_16_Verify the icon a new image is for MPO12 Server 4xLC patched to DM08
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_16
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}
    ${port_list}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}
    ${tc_wo_name}    Set Variable    WO_SM29998_16

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Server 01 and DM08 Panel 01 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_01}    ${Module 1A},True,${LC 12 Port},${DM08}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_NAME}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_NAME}    ${01}    portType=${MPO12}       

    # 4. Open Patching window and create patching from Server 01 / 01 to Panel 01 /  01-04 with 4xLC
    Open Patching Window    ${tree_node_rack}/${SERVER_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SERVER_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})
    ...    portsFrom=${01}    portsTo=${MPO1-01},${MPO1-02},${MPO1-03},${MPO1-04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    	
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Patching    ${pair_list}[${i}]
    \    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_4LC_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}    

	# 7. Trace Server 01 / 01, Panel 01 / 01-04 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${SERVER_NAME}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1   connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${MPO1-01}    ${PortFDUncabledInUse}

	# 9. Trace Server 01 / 01, Panel 01 / 01-04
    Open Trace Window    ${tree_node_rack}/${SERVER_NAME}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    \    Close Trace Window

SM-29998_17_Verify the icon a new image is for MPO12 Switch 4xLC patched to DM12
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_17
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${1-1}    ${2-2}    ${3-3}    ${4-4}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}
    ${tc_wo_name}    Set Variable    WO_SM29998_17

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Switch 01 and LC Panel 01 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_01}    ${Module 1A},True,${LC 12 Port},${DM12}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${01}    portType=${MPO12}

    # 4. Open Patching window and create patching from Switch 01 / 01 to Panel 01 /  01-04 with 4xLC  01-04 with 4xLC
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM12})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    	
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Patching    ${pair_list}[${i}]
    \    Check Trace Object On Patching    indexObject=2    connectionType=${TRACE_MPO12_4LC_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}    

	# 7. Trace Switch 01 / 01, Panel 01 / 01-04 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM12})    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_4LC_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}	

	# 9. Trace Switch 01 / 01, Panel 01 / 01-04
    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM12})    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_4LC_PATCHING}
    \    Close Trace Window

SM-29998_18_Verify the icon a new image is for MPO12 Switch 6xLC EB patched to LC Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_18
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list_1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}
    ${pair_list_2}    Create List    ${Pair 5}    ${Pair 6}
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}
    ${port_list_2}    Create List    ${05}    ${06}
    ${tc_wo_name}    Set Variable    WO_SM29998_18

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Switch 01 and DM12 Panel 01 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_01}    portType=${LC}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${01}    portType=${MPO12}

    # 4. Open Patching window and create patching from Switch 01 / 01 to Panel 01 /  01-06 with 6xLC EB
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_01}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	Select View Trace Tab On Patching    ${Pair 5}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
    \    Check Trace Object On Patching    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}   
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}    

	# 7. Trace Switch 01 / 01, Panel 01 / 01-06 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list_1})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${port_list_1}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window
    :FOR    ${i}    IN RANGE    0    len(${port_list_2})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${port_list_2}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window
	
	# 8. Complete the work order
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}

	# 9. Trace Switch 01 / 01, Panel 01 / 01-06
    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list_2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list_1})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${port_list_1}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window
    :FOR    ${i}    IN RANGE    0    len(${port_list_2})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${port_list_2}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window

SM-29998_19_Verify the icon a new image is for MPO12 Server 6xLC EB patched to LC Panel (Beta)
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_19
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}    
    ${pair_list_1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${tc_wo_name}    Set Variable    WO_SM29998_19

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Server 01 and LC Panel (Beta) 01 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_01}    ${Module 1A},True,${LC 12 Port},${Beta}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_NAME}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_NAME}    ${01}    portType=${MPO12}       

    # 4. Open Patching window and create patching from Server 01 / 01 to Panel 01 /  01-06 with 6xLC EB
    Open Patching Window    ${tree_node_rack}/${SERVER_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SERVER_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${Beta})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	Select View Trace Tab On Patching    ${Pair 5}
	Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
    \    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}

	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}  
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}  

	# 7. Trace Server 01 / 01, Panel 01 / 01-06 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${SERVER_NAME}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    Close Trace Window    

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${Beta})    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window 
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}

	# 9. Trace Server 01 / 01, Panel 01 / 01-06
    Open Trace Window    ${tree_node_rack}/${SERVER_NAME}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    Close Trace Window

    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${Beta})    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    \    Close Trace Window

SM-29998_20_Verify the icon a new image is for MPO12 Switch 6xLC EB patched to DM08
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_20
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
   
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list_1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}
    ${pair_list_2}    Create List    ${Pair 5}    ${Pair 6}
    ${port_list_1}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}
    ${port_list_2}    Create List    ${MPO2-01}    ${MPO2-02}

    ${tc_wo_name}    Set Variable    WO_SM29998_20

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Switch 01 and DM08 Panel 01 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_01}    ${Module 1A},True,${LC 12 Port},${DM08}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${01}    portType=${MPO12}
      
    # 4. Open Patching window and create patching from Switch 01 / 01 to Panel 01 /  01-06 with 6xLC EB
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})
    ...    portsFrom=${01}    portsTo=${MPO1-01},${MPO1-02},${MPO1-03},${MPO1-04},${MPO2-01},${MPO2-02}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Select View Trace Tab On Patching    ${Pair 5}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
       	
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
    \    Check Trace Object On Patching    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    
	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}  
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}  

	# 7. Trace Switch 01 / 01, Panel 01 / 01-06 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    0    len(${port_list_1})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list_1}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window
    :FOR    ${i}    IN RANGE    0    len(${port_list_2})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list_2}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window 
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	Wait For Port Icon Exist On Content Table    ${MPO1-01}    ${PortFDUncabledInUse}	

	# 9. Trace Switch 01 / 01, Panel 01 / 01-06
    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
    \    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list_2})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    0    len(${port_list_1})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list_1}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=2    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window
    :FOR    ${i}    IN RANGE    0    len(${port_list_2})
    \    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}/${Module 1A} (${DM08})    ${port_list_2}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Close Trace Window

SM-29998_21_Verify the icon a new image is for MPO12 Panel 6xLC EB patched to DM12
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29998_21
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list_1}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}

    ${tc_wo_name}    Set Variable    WO_SM29998_21

	# 1. Launch and log into SM Web
	# 2. Add Building / Floor / Room / Rack
	# 3. Add MPO12 Panel 01 and DM12 Panel 02 to Rack
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_01}    portType=${MPO}  
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_02}    ${Module 1A},True,${LC 12 Port},${DM12}

    # 4. Open Patching window and create patching from Panel 01 / 01 to Panel 02 /  01-06 with 4xLC
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_01}    01
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_01}    patchTo=${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${DM12})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=no

	# 5. Go to Circuit Trace tab in Patching window and observe
    Select View Tab On Patching    ${Circuit Trace}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Select View Trace Tab On Patching    ${Pair 5}
    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
    \    Check Trace Object On Patching    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    
	# 6. Complete create patching with a work order
	Save Patching Window
	Create Work Order    ${tc_wo_name}    
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUseScheduled}

	# 7. Trace Panel 01 / 01, Panel 02 / 01-06 and select Scheduled view
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	Select View Type On Trace    Scheduled
    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${DM12})    ${port_list}[${i}]    
	\    Select View Type On Trace    Scheduled
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    \    Close Trace Window

	# 8. Complete the work order
	Open Work Order Queue Window 
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}

	# 9. 9. Trace Panel 01 / 01, Panel 02 / 01-06
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_01}    ${01}
	    :FOR    ${i}    IN RANGE    0    len(${pair_list})    	         
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})        
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_02}/${Module 1A} (${DM12})    ${port_list}[${i}]    
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    \    Close Trace Window
