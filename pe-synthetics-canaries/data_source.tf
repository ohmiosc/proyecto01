data "archive_file" "node_h" {
  type        = "zip"
  
  source_dir = "pe_ms_cip"
  output_path = "pe_ms_cipv2.zip"
}
