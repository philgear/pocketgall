import { Pipe, PipeTransform, Inject, PLATFORM_ID } from '@angular/core';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { isPlatformBrowser } from '@angular/common';
import DOMPurify from 'dompurify';

@Pipe({
    name: 'safeHtml',
    standalone: true
})
export class SafeHtmlPipe implements PipeTransform {
    private isBrowser: boolean;

    constructor(
        private sanitizer: DomSanitizer,
        @Inject(PLATFORM_ID) platformId: Object
    ) {
        this.isBrowser = isPlatformBrowser(platformId);
    }

    transform(value: string): SafeHtml {
        if (!value) return value;
        
        let cleanHtml = value;
        if (this.isBrowser && typeof DOMPurify.sanitize === 'function') {
            cleanHtml = DOMPurify.sanitize(value, {
                ADD_TAGS: ['svg', 'path', 'g', 'circle', 'line', 'polygon', 'rect'],
                ADD_ATTR: ['viewBox', 'fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin', 'd']
            });
        }
        
        return this.sanitizer.bypassSecurityTrustHtml(cleanHtml);
    }
}
