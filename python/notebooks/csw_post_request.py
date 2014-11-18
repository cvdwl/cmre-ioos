# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import requests, json

# <codecell>

headers = {'Content-Type': 'application/xml'}

# <codecell>

endpoint = 'http://www.ngdc.noaa.gov/geoportal/csw'
##endpoint = 'http://172.21.173.15/geonetwork/srv/eng/csw'
endpoint = 'http://scsrv26v:8000'

# <codecell>

input="""
<?xml version="1.0" encoding="UTF-8"?>
<csw:GetRecords xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" service="CSW" version="2.0.2">
  <csw:Query typeNames="csw:Record">
    <csw:Constraint version="1.1.0">
      <Filter xmlns="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml">
        <PropertyIsLike wildCard="%" singleChar="_" escape="\\">
          <PropertyName>AnyText</PropertyName>
          <Literal>%temperature%</Literal>
        </PropertyIsLike>
      </Filter>
    </csw:Constraint>
  </csw:Query>
</csw:GetRecords>
"""

# <codecell>

input='''
<csw:GetRecords xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" version="2.0.2" service="CSW" resultType="results" startPosition="1" maxRecords="11" outputSchema="http://www.isotc211.org/2005/gmd"> <csw:Query typeNames="csw:Record" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml" > 
<csw:ElementSetName>full</csw:ElementSetName> 
<csw:Constraint version="1.1.0"> 
  <ogc:Filter>
    <ogc:And>
      <ogc:PropertyIsGreaterThan> 
      <ogc:PropertyName>apiso:modified</ogc:PropertyName> <ogc:Literal>2014-09-30</ogc:Literal>
      </ogc:PropertyIsGreaterThan> 
      <ogc:PropertyIsLessThan> 
      <ogc:PropertyName>apiso:modified</ogc:PropertyName> <ogc:Literal>2014-10-02</ogc:Literal>
      </ogc:PropertyIsLessThan> 
    </ogc:And>
  </ogc:Filter>
</csw:Constraint> 
</csw:Query> 
</csw:GetRecords> 
'''

# <codecell>

input='''
<csw:GetRecords xmlns:csw='http://www.opengis.net/cat/csw/2.0.2' version='2.0.2' service='CSW' resultType='results' startPosition='1' maxRecords='15'><csw:Query typeNames='csw:Record' xmlns:ogc='http://www.opengis.net/ogc' xmlns:gml='http://www.opengis.net/gml'><csw:ElementSetName>full</csw:ElementSetName><csw:Constraint version='1.1.0'>
<ogc:Filter>
<ogc:And>
<ogc:PropertyIsLike wildCard='%' escapeChar='' singleChar='?'>
<ogc:PropertyName>csw:AnyText</ogc:PropertyName>
<ogc:Literal>%temperature%</ogc:Literal>
</ogc:PropertyIsLike>
<ogc:BBOX>
<ogc:PropertyName>ows:BoundingBox</ogc:PropertyName>
<gml:Envelope><gml:lowerCorner>-20.6375834 0.3145072444444</gml:lowerCorner><gml:upperCorner>20.0 55.8652707555555</gml:upperCorner></gml:Envelope>
</ogc:BBOX>
</ogc:And>
</ogc:Filter>
</csw:Constraint>
</csw:Query></csw:GetRecords>
'''

# <codecell>

xml_string=requests.post(endpoint, data=input, headers=headers).text

# <codecell>

print xml_string

# <codecell>


# <codecell>


