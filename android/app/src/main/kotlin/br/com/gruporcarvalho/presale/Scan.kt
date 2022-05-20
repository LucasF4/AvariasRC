package br.com.gruporcarvalho.avarias

class Scan(val data: String, val symbology: String, val dateTime: String)
{
  fun toJson(): String{
      return "{\"scanData\":\"$data\",\"symbology\":\"$symbology\",\"dateTime\":\"$dateTime\"}"
  }
}