report 60101 "Calculate Plan for Job"
{
    ApplicationArea = All;
    Caption = 'Calculate Plan for Job';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("Low-Level Code") where(Type = const(Inventory), Blocked = const(false), "Replenishment System" = const(Purchase));
            RequestFilterFields = "No.", "Vendor No.";
            trigger OnAfterGetRecord()
            var
                JobPlanningLine: Record "Job Planning Line";
                ItemRec: Record Item;
                PurchaseLine: Record "Purchase Line";
                SupplyQty: Decimal;
                ItemLedEnty: Record "Item Ledger Entry";
                DemandQuantity: Decimal;
                PlanQty: Decimal;
            begin
                Clear(SupplyQty);
                Clear(DemandQuantity);
                Clear(PlanQty);
                PurchaseLine.Reset();
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                PurchaseLine.SetRange("No.", Item."No.");
                //PurchaseLine.SetRange("Planned Receipt Date", 0D, EndDate);
                PurchaseLine.CalcSums(Quantity);
                SupplyQty := PurchaseLine.Quantity;
                ItemLedEnty.Reset();
                ItemLedEnty.SetRange("Item No.", Item."No.");
                //ItemLedEnty.SetRange("Posting Date", 0D, EndDate);
                ItemLedEnty.CalcSums(Quantity);
                SupplyQty := SupplyQty + ItemLedEnty.Quantity;
                JobPlanningLine.Reset();
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
                JobPlanningLine.SetRange("No.", Item."No.");
                //JobPlanningLine.SetRange("Planned Delivery Date", StartDate, EndDate);
                JobPlanningLine.SetRange(Completed, false);
                if JobNo <> '' then
                    JobPlanningLine.SetRange("Job No.", JobNo);
                JobPlanningLine.CalcSums("Planned Qty", Quantity);
                DemandQuantity := JobPlanningLine."Planned Qty" - JobPlanningLine.Quantity;
                if SupplyQty >= DemandQuantity then
                    exit
                else begin
                    PlanQty := DemandQuantity - SupplyQty;
                    CreateRequistion(Item, PlanQty);
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(JobNo; JobNo)
                    {
                        Caption = 'Job No.';
                        TableRelation = Job."No.";
                        ApplicationArea = all;
                    }
                }
            }
        }
    }
    var
        StartDate: Date;
        EndDate: Date;
        CurrTemplateName: Code[10];
        CurrWorksheetName: Code[10];
        JobNo: Code[20];

    procedure CreateRequistion(Item: Record Item; PlanQty: Decimal)
    var
        RequsitionLine: Record "Requisition Line";
        LineNo: Integer;
    begin
        Clear(LineNo);
        RequsitionLine.SetRange(Type, RequsitionLine.Type::Item);
        RequsitionLine.SetRange("No.", Item."No.");
        if RequsitionLine.Find('-') then
            repeat
                RequsitionLine.Delete(true);
            until RequsitionLine.Next() = 0;
        RequsitionLine.Reset();
        if RequsitionLine.FindLast() then
            LineNo := RequsitionLine."Line No." + 10000
        else
            LineNo := 10000;
        RequsitionLine.Reset();
        RequsitionLine.Init();
        RequsitionLine."Worksheet Template Name" := CurrTemplateName;
        RequsitionLine."Journal Batch Name" := CurrWorksheetName;
        RequsitionLine."Line No." := LineNo;
        RequsitionLine.Insert();
        RequsitionLine.Validate(Type, RequsitionLine.Type::Item);
        RequsitionLine.Validate("No.", Item."No.");
        RequsitionLine.Validate("Action Message", RequsitionLine."Action Message"::New);
        RequsitionLine.Validate("Location Code", 'CSI');
        RequsitionLine.Validate(Quantity, PlanQty);
        RequsitionLine.Validate("Unit Cost", Item."Unit Cost");
        RequsitionLine.Validate("Due Date", EndDate);
        RequsitionLine.Validate("Vendor No.", Item."Vendor No.");
        RequsitionLine.Validate("Replenishment System", Item."Replenishment System");
        RequsitionLine.Modify(true);
    end;

    procedure SetTemplAndWorksheet(TemplateName: Code[10]; WorksheetName: Code[10])
    begin
        CurrTemplateName := TemplateName;
        CurrWorksheetName := WorksheetName;
    end;
}
