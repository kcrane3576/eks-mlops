variable "access_analyzer_name" {
  type        = string
  description = "Access analyzer name"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}