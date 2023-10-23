using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;  // creating DPF files
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;

namespace TCT
{
    public partial class PrintDocument : System.Web.UI.Page
    {
        decimal TotalPriceSum = 0;
        decimal QuantitySum = 0;
        int PagePreviewLineCount = 999; // used for putting page breaks in correct places (start with 999 so first element would start on next page)
        int PagePreviewLinesPerPage = 50; // page break after every X "lines"

        protected void Page_Load(object sender, EventArgs e)
        {
            if (PreviousPage != null)
            {
                ContentPlaceHolder content = (ContentPlaceHolder)PreviousPage.Master.FindControl("ContentPlaceHolder1");
                if (content != null)
                {
                    ListBox ListBoxDocs = (ListBox)content.FindControl("ListBoxDocuments");
                    if (ListBoxDocs != null)
                    {
                        SqlDataSource_DocumentHeader.SelectParameters["DocumentHeaderID"].DefaultValue = ListBoxDocs.SelectedValue;
                        SqlDataSource_DocumentLine.SelectParameters["DocumentHeaderID"].DefaultValue = ListBoxDocs.SelectedValue;
                        SqlDataSource_DocumentLineForComponents.SelectParameters["DocumentHeaderID"].DefaultValue = ListBoxDocs.SelectedValue;
                    }
                }
            }
            if (SqlDataSource_DocumentHeader.SelectParameters["DocumentHeaderID"].DefaultValue == "0")
            {
                Response.Redirect("~/Shipping.aspx");
            }

            ///* PDF creation */
            //SqlDataSource_DocumentHeader.DataBind();
            ////LogoImage.ImageUrl = Server.MapPath("Images") + "\\tct.jpg";
            //Response.ContentType = "application/pdf";
            //Response.AddHeader("content-disposition", "attachment;filename=Document_" + SqlDataSource_DocumentHeader.SelectParameters["DocumentHeaderID"].DefaultValue + ".pdf");
            //Response.Cache.SetCacheability(HttpCacheability.NoCache);
            //StringWriter sw = new StringWriter();
            //HtmlTextWriter hw = new HtmlTextWriter(sw);
            // //StyleSheet styles = new StyleSheet();
            // //styles.LoadTagStyle("p", "page-break-before", "always");
            // //styles.LoadTagStyle("p", "page-break-before", "always");
            //this.Page.RenderControl(hw);
            //StringReader sr = new StringReader(sw.ToString());
            //Document pdfDoc = new Document(); // create a PDF document object in memory with the default settings
            //HTMLWorker htmlparser = new HTMLWorker(pdfDoc);
            //PdfWriter.GetInstance(pdfDoc, Response.OutputStream);
            //pdfDoc.Open();
            //htmlparser.Parse(sr);
            // //pdfDoc.Add(new Paragraph("My first PDF"));
            //pdfDoc.Close();
            //Response.Write(pdfDoc);
            //Response.End();
        }

        protected void FormViewDocumentHeader_DataBound(object sender, EventArgs e)
        {
            String DocType = DataBinder.Eval(FormViewDocumentHeader.DataItem, "DocumentType").ToString();
            if (DocType == "1")
            {
                GridViewDocumentLine.Visible = true;
                PanelFooter.Visible = true;
                RepeaterDocumentMaterial.Visible = true;
            }
            if (DocType == "2")
            {
                GridViewDocumentLineForComponents.Visible = true;
            }
        }

        protected void GridViewDocumentLine_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                TotalPriceSum += Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "TotalPrice"));
                QuantitySum += Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "Quantity"));
            }
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                Label lbl1 = (Label)e.Row.FindControl("TotalPriceSumLabel");
                Label lbl2 = (Label)e.Row.FindControl("QuantitySumLabel");
                lbl1.Text = Math.Round(TotalPriceSum, 2).ToString();
                lbl2.Text = Math.Round(QuantitySum, 2).ToString();
            }
        }

        protected void RepeaterDocumentMaterial_ItemDataBound(Object Sender, RepeaterItemEventArgs e)
        {
            SqlDataSource sql = (SqlDataSource)e.Item.FindControl("SqlDataSource_DocumentMaterial");
            sql.SelectParameters["DocumentLineID"].DefaultValue = DataBinder.Eval(e.Item.DataItem, "DocumentLineID").ToString(); 
        }

        protected void GridViewDocumentMaterial_DataBound(object sender, EventArgs e)
        {
            GridView gv = (GridView)sender;
            if (PagePreviewLineCount + gv.Rows.Count > PagePreviewLinesPerPage)
            {
                Panel RepItemPanel = (Panel)gv.NamingContainer.FindControl("PuccMaterialsPanel");
                RepItemPanel.CssClass = "nextpage";
                PagePreviewLineCount = 0;
            }
            if (gv.Rows.Count > 0) PagePreviewLineCount += gv.Rows.Count + 11;  // 11 rows is roughly the header height (of PuccMaterialsPanel)
        }

        protected void SqlDataSource_DocumentMaterial_Selected(object sender, SqlDataSourceStatusEventArgs e)
        {
            //PagePreviewLineCount += e.AffectedRows + 11;  // 11 rows is roughly the header height (of PuccMaterialsPanel)
        }
    }
}