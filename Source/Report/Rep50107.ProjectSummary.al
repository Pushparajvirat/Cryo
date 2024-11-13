report 60107 "Project Summary"
{
    ApplicationArea = All;
    Caption = 'Project Quote';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = 'Source/Layouts/ProjectSummary.rdl';
    DefaultLayout = RDLC;
    dataset
    {
        dataitem(Job; Job)
        {
            RequestFilterFields = "No.";
            column(No_; "No.") { }
            column(Bill_to_Customer_No_; "Bill-to Customer No.") { }
            column(Bill_to_Name; "Bill-to Name") { }
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyAddress; CompanyInformation.Address) { }
            column(CompanyAddress2; CompanyInformation."Address 2") { }
            column(CompanyCity; CompanyInformation.City) { }
            column(CompCountryName; CompanyCountryName) { }
            column(CompanyInformation; CompanyInformation."Post Code") { }
            column(CompanyPciture; CompanyInformation.Picture) { }
            column(Sell_to_Contact; "Sell-to Contact") { }
            column(External_Document_No_; "External Document No.") { }
            column(Service_Item_No_; "Service Item No.") { }
            column(Your_Reference; "Your Reference") { }
            dataitem("Job Task"; "Job Task")
            {
                DataItemTableView = where("Job Task Type" = const("Job Task Type"::Posting));
                DataItemLink = "Job No." = field("No.");
                RequestFilterFields = "Sorting Order";

                column(Job_Task_No_; "Job Task No.") { }
                column(Description_2; RecDescription) { }
                column(Priority; Priority) { }
                column(Sorting_Order; SortingOrder) { }


                dataitem(Integer; Integer)
                {
                    DataItemLinkReference = "Job Task";
                    column(MaterialValue; MaterialValue) { }
                    column(LabourValue; LabourValue) { }
                    column(FlatRateValue; FlatRateValue) { }
                    column(SubContractorValue; SubContractorValue) { }
                    column(SubTotal; SubTotal) { }
                    trigger OnAfterGetRecord()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        Clear(MaterialValue);
                        Clear(LabourValue);
                        Clear(FlatRateValue);
                        Clear(SubContractorValue);
                        Clear(SubTotal);
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", "Job Task"."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task"."Job Task No.");
                        // JobPlanningLine.SetFilter("Line Type", '<>Budget');
                        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
                        JobPlanningLine.SetRange("Sub Contractor", false);
                        JobPlanningLine.SetRange("Flat Rate", false);
                        if JobPlanningLine.FindSet() then begin
                            repeat
                                // JobPlanningLine.CalcSums("Unit Price");
                                // JobPlanningLine.CalcSums(Quantity);
                                MaterialValue += (JobPlanningLine."Quote Quntity") * (JobPlanningLine."Unit Price");
                            until JobPlanningLine.Next() = 0;
                        end;
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", "Job Task"."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task"."Job Task No.");
                        // JobPlanningLine.SetFilter("Line Type", '<>Budget');
                        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
                        JobPlanningLine.SetRange("Sub Contractor", false);
                        JobPlanningLine.SetRange("Flat Rate", false);
                        if JobPlanningLine.FindSet() then begin
                            repeat
                                // JobPlanningLine.CalcSums("Unit Price");
                                // JobPlanningLine.CalcSums(Quantity);
                                LabourValue += (JobPlanningLine."Quote Quntity") * (JobPlanningLine."Unit Price");
                            until JobPlanningLine.Next() = 0;
                        end;
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", "Job Task"."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task"."Job Task No.");
                        // JobPlanningLine.SetFilter("Line Type", '<>Budget');
                        JobPlanningLine.SetRange("Flat Rate", true);
                        if JobPlanningLine.FindSet() then begin
                            repeat
                                // JobPlanningLine.CalcSums("Unit Price");
                                // JobPlanningLine.CalcSums(Quantity);
                                FlatRateValue += (JobPlanningLine."Quote Quntity") * (JobPlanningLine."Unit Price");
                            until JobPlanningLine.Next() = 0;
                        end;
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", "Job Task"."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task"."Job Task No.");
                        // JobPlanningLine.SetFilter("Line Type", '<>Budget');
                        JobPlanningLine.SetRange("Sub Contractor", true);
                        if JobPlanningLine.FindSet() then begin
                            repeat
                                // JobPlanningLine.CalcSums("Unit Price");
                                // JobPlanningLine.CalcSums(Quantity);
                                SubContractorValue += (JobPlanningLine."Quote Quntity") * (JobPlanningLine."Unit Price");
                            until JobPlanningLine.Next() = 0;
                        end;
                        SubTotal := MaterialValue + LabourValue + FlatRateValue + SubContractorValue;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1);
                    end;
                }
                trigger OnAfterGetRecord()
                var
                    JobTaskLines: Record "Job Task";
                begin
                    Clear(SortingOrder);
                    Clear(RecDescription);
                    if "Job Task"."Sorting Order" <> '' then
                        Evaluate(SortingOrder, "Job Task"."Sorting Order")
                    else
                        SortingOrder := 0;
                    JobTaskLines.Reset();
                    JobTaskLines.SetRange("Job No.", Job."No.");
                    JobTaskLines.SetRange("Sorting Order", "Job Task"."Sorting Order");
                    if JobTaskLines.FindSet() then
                        repeat
                            if RecDescription = '' then
                                RecDescription := JobTaskLines."Description 2"
                            else
                                RecDescription := RecDescription + ' ' + JobTaskLines."Description 2";
                        until JobTaskLines.Next() = 0;
                end;

            }
            trigger OnAfterGetRecord()
            var
                CountryRegion: Record "Country/Region";
            begin
                if CountryRegion.Get(CompanyInformation."Country/Region Code") then
                    CompanyCountryName := CountryRegion.Name;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        CompanyCountryName: Text[50];
        MaterialValue: Decimal;
        LabourValue: Decimal;
        FlatRateValue: Decimal;
        SubContractorValue: Decimal;
        SubTotal: Decimal;
        SortingOrder: Integer;
        RecDescription: Text;
}
