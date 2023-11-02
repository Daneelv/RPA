*** Settings ***
Documentation       Intelligent Document Processing using various document
...    understanding engines.

Library    Collections
Library    RPA.DocumentAI
Library    RPA.Robocorp.WorkItems


*** Variables ***
${INVOICE_PDF_FILE}    devdata${/}parallels.pdf
${INVOICE_PNG_FILE}    devdata${/}parallels.png

${INVOICE_PNG_URL}    https://github.com/robocorp/example-document-ai/raw/master/devdata/parallels.png


*** Keywords ***
Init Google
    [Arguments]    ${region}
    Init Engine    google    vault=document_ai:serviceaccount    region=${region}


Init Base64
    Init Engine    base64ai    vault=document_ai:base64ai


Init Nanonets
    Init Engine    nanonets    vault=document_ai:nanonets


Process Document
    &{payload} =    Get Work Item Variables
    &{fake_email} =    Create Dictionary    body    ${payload}
    &{parsed_email} =    Get Work Item Variable    email    ${fake_email}
    &{engines} =    Set Variable    ${parsed_email}[body]

    FOR    ${engine}    IN    @{engines}
        Log    Scanning with engine: ${engine}...
        ${config} =    Get From Dictionary    ${engines}    ${engine}
        &{auth} =    Get From Dictionary    ${config}    auth
        Init Engine    ${engine}    &{auth}

        &{predict} =    Get From Dictionary    ${config}    predict
        @{invoices} =    Get Work Item Files    invoice.*    dirname=${OUTPUT_DIR}
        FOR    ${invoice}    IN    @{invoices}
            Log    Processing file: ${invoice}
            Predict    ${invoice}    &{predict}
            @{data} =    Get Result
            Log List    ${data}
        END
    END


*** Tasks ***
Document AI Google
    ${region} =    Set Variable    eu  # default 'us'
    Init Google    ${region}

    Predict    ${INVOICE_PDF_FILE}    model=df1d166771005ff4
    ...    project_id=complete-agency-347912    region=${region}
    @{data} =    Get Result
    Log List    ${data}


Document AI Base64
    [Setup]    Init Base64

    Predict    ${INVOICE_PNG_URL}    mock=${False}
    @{data} =    Get Result    extended=${True}
    Log List    ${data}


Document AI Nanonets
    [Setup]    Init Nanonets

    Predict    ${INVOICE_PDF_FILE}    model=858e4b37-6679-4552-9481-d5497dfc0b4a
    @{data} =    Get Result
    Log List    ${data}


Document AI All
    # Initialize all the engines one by one. (authorization)
    ${google_region} =    Set Variable    eu
    Init Google    ${google_region}
    Init Base64
    Init Nanonets

    # Now setup the models and other required data for the prediction given each engine.
    &{google_params} =    Create Dictionary
    ...    model    df1d166771005ff4
    ...    project_id    complete-agency-347912
    ...    region    ${google_region}
    &{base64_params} =    Create Dictionary
    ...    model    finance/invoice
    &{nanonets_params} =    Create Dictionary
    ...    model    858e4b37-6679-4552-9481-d5497dfc0b4a
    &{engines} =    Create Dictionary
    ...    google    ${google_params}
    ...    base64ai    ${base64_params}
    ...    nanonets    ${nanonets_params}

    FOR    ${engine}    IN    @{engines}
        Switch Engine    ${engine}
        Log    Scanning with engine: ${engine}...

        &{params} =    Get From Dictionary    ${engines}    ${engine}
        Predict    ${INVOICE_PNG_FILE}    &{params}
        @{data} =    Get Result
        Log List    ${data}
    END


Document AI Work Items
    For Each Input Work Item    Process Document    return_results=${False}
