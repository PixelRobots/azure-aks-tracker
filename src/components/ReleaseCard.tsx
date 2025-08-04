import { EnhancedRelease } from '@/lib/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { 
  Calendar, 
  ExternalLink, 
  AlertTriangle, 
  Shield, 
  Key, 
  Sparkles,
  MapPin,
  Bug
} from '@phosphor-icons/react';

interface ReleaseCardProps {
  release: EnhancedRelease;
}

export function ReleaseCard({ release }: ReleaseCardProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getSeverityColor = (severity: string) => {
    switch (severity.toLowerCase()) {
      case 'critical': return 'bg-red-100 text-red-800 border-red-200';
      case 'high': return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'medium': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'low': return 'bg-blue-100 text-blue-800 border-blue-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  return (
    <Card className="w-full">
      <CardHeader className="pb-4">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <CardTitle className="text-xl">{release.version}</CardTitle>
              {release.isPrerelease && (
                <Badge variant="outline" className="text-xs">
                  Pre-release
                </Badge>
              )}
            </div>
            
            <div className="flex items-center gap-4 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <Calendar size={14} />
                {formatDate(release.publishedAt)}
              </div>
              
              {release.regions.length > 0 && (
                <div className="flex items-center gap-1">
                  <MapPin size={14} />
                  {release.regions.length} region{release.regions.length !== 1 ? 's' : ''}
                </div>
              )}
              
              {release.cves.length > 0 && (
                <div className="flex items-center gap-1">
                  <Shield size={14} />
                  {release.cves.length} CVE{release.cves.length !== 1 ? 's' : ''}
                </div>
              )}
            </div>
          </div>
          
          <Button variant="outline" size="sm" asChild>
            <a 
              href={release.htmlUrl} 
              target="_blank" 
              rel="noopener noreferrer"
              className="flex items-center gap-1"
            >
              <ExternalLink size={14} />
              View Release
            </a>
          </Button>
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* Summary */}
        {release.summary && (
          <div>
            <p className="text-sm leading-relaxed">{release.summary}</p>
          </div>
        )}

        {/* Breaking Changes */}
        {release.breakingChanges.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-2">
              <AlertTriangle size={16} className="text-destructive" />
              <h4 className="font-medium text-sm">Breaking Changes</h4>
            </div>
            <ul className="space-y-1">
              {release.breakingChanges.map((change, index) => (
                <li key={index} className="text-sm text-muted-foreground pl-4 border-l-2 border-destructive/20">
                  {change}
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Key Features */}
        {release.keyFeatures.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Sparkles size={16} className="text-primary" />
              <h4 className="font-medium text-sm">Key Features</h4>
            </div>
            <ul className="space-y-1">
              {release.keyFeatures.map((feature, index) => (
                <li key={index} className="text-sm text-muted-foreground pl-4 border-l-2 border-primary/20">
                  {feature}
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Good to Know */}
        {release.goodToKnow.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Key size={16} className="text-blue-600" />
              <h4 className="font-medium text-sm">Good to Know</h4>
            </div>
            <ul className="space-y-1">
              {release.goodToKnow.map((item, index) => (
                <li key={index} className="text-sm text-muted-foreground pl-4 border-l-2 border-blue-200">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* CVEs */}
        {release.cves.length > 0 && (
          <>
            <Separator />
            <div>
              <div className="flex items-center gap-2 mb-3">
                <Bug size={16} className="text-orange-600" />
                <h4 className="font-medium text-sm">Security Issues (CVEs)</h4>
              </div>
              <div className="space-y-2">
                {release.cves.map((cve, index) => (
                  <div key={index} className="flex items-start gap-3 p-3 rounded-lg border bg-muted/30">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-mono text-sm font-medium">{cve.id}</span>
                        <Badge 
                          variant="outline" 
                          className={`text-xs ${getSeverityColor(cve.severity)}`}
                        >
                          {cve.severity}
                        </Badge>
                        {cve.mitigated && (
                          <Badge variant="outline" className="text-xs bg-green-100 text-green-800 border-green-200">
                            Mitigated
                          </Badge>
                        )}
                      </div>
                      {cve.description && (
                        <p className="text-xs text-muted-foreground">{cve.description}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </>
        )}

        {/* Regions */}
        {release.regions.length > 0 && (
          <>
            <Separator />
            <div>
              <div className="flex items-center gap-2 mb-2">
                <MapPin size={16} className="text-green-600" />
                <h4 className="font-medium text-sm">Available Regions</h4>
                {release.rolloutStatus && (
                  <Badge variant="outline" className="text-xs">
                    {release.rolloutStatus}
                  </Badge>
                )}
              </div>
              <div className="flex flex-wrap gap-1">
                {release.regions.map((region, index) => (
                  <Badge key={index} variant="secondary" className="text-xs">
                    {region}
                  </Badge>
                ))}
              </div>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}