variable "marketplace_source_images" {  
   type = map(object({ 
     ocid = string  
     is_pricing_associated = bool  
     compatible_shapes = set(string)  }))  
   default = {    
     main_mktpl_image = {     
       ocid = "ocid1.image.oc1..aaaaaaaaw5ucng4rfvsg5zwvlicfwcz53fhfuaepwikesicbxlpmukiseeia"      
       is_pricing_associated = true      
       compatible_shapes = []    
     }} 
}
