tableextension 60100 "Requisition Line Ext" extends "Requisition Line"
{
    fields
    {
        field(60100; "Qty. on Inventory"; Decimal)
        {
            Caption = 'Qty. on Inventory';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("No."), "Location Code" = field("Location Code"), "Variant Code" = field("Variant Code")));
        }
    }
}
