pageextension 60101 "Req. Worksheet Ext" extends "Req. Worksheet"
{
    layout
    {
        addafter("Qty. on Purch. Order")
        {

            field("Qty on Inventory"; Rec."Qty. on Inventory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty on Inventory field.', Comment = '%';
            }
        }
    }
    actions
    {
        addafter(CalculatePlan)
        {
            action(CalculatePlanJob)
            {
                Caption = 'Calculate Project';
                Image = CalculatePlan;
                ApplicationArea = all;
                trigger OnAction()
                var
                    CalculatePlanJob: Report "Calculate Plan for Job";
                begin
                    CalculatePlanJob.SetTemplAndWorksheet(Rec."Worksheet Template Name", Rec."Journal Batch Name");
                    CalculatePlanJob.RunModal();
                    Clear(CalculatePlan);
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(CalculatePlanJobRef; CalculatePlanJob)
            {
            }
        }
    }
}
