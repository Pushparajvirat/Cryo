pageextension 60102 "Job Planning Line Ext" extends "Job Planning Lines"
{
    layout
    {
        addafter("Unit Price")
        {

            field("Quote Quntity"; Rec."Quote Quntity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Quote Quntity field.', Comment = '%';
            }
        }
    }
}
