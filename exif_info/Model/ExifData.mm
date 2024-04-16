//
//  ExifData.m
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "ExifData.h"
/**
 * https://www.exiv2.org/tags.html
 */

static const NSInteger kTagArrayCount = 309;

struct TagInfo {
    TagInfo(uint16_t tag, const char *name, const char *title, const char *description):tag_(tag), name_(name), title_(title), description_(description) {}
    uint16_t        tag_;
    const char *    name_;
    const char *    title_;
    const char *    description_;
};

static const TagInfo kTagInfoArray[] = {
    TagInfo(0x000b, "ProcessingSoftware",           "Processing Software",              "The name and version of the software used to post-process the picture."), // ACD Systems Digital Imaging tag
    TagInfo(0x00fe, "NewSubfileType",               "New Subfile Type",                 "A general indication of the kind of data contained in this subfile."),
    TagInfo(0x00ff, "SubfileType",                  "Subfile Type",                     "A general indication of the kind of data contained in this subfile."),
    TagInfo(0x0100, "ImageWidth",                   "Image Width",                      "The number of columns of image data"),
    TagInfo(0x0101, "ImageLength",                  "Image Length",                     "The number of rows of image data."),
    TagInfo(0x0102, "BitsPerSample",                "Bits per Sample",                  "The number of bits per image component."),
    TagInfo(0x0103, "Compression",                  "Compression",                      "The compression scheme used for the image data."),
    TagInfo(0x0106, "PhotometricInterpretation",    "Photometric Interpretation",       "The pixel composition."),
    TagInfo(0x0107, "Thresholding",                 "Thresholding",                     "For black and white TIFF files that represent shades of gray, the technique used to convert from gray to black and white pixels."),
    TagInfo(0x0108, "CellWidth",                    "Cell Width",                       "The width of the dithering or halftoning matrix used to create a dithered or halftoned bilevel file."),
    TagInfo(0x0109, "CellLength",                   "Cell Length",                      "The length of the dithering or halftoning matrix used to create a dithered or halftoned bilevel file."),
    TagInfo(0x010a, "FillOrder",                    "Fill Order",                       "The logical order of bits within a byte"),
    TagInfo(0x010d, "DocumentName",                 "Document Name",                    "The name of the document from which this image was scanned"),
    TagInfo(0x010e, "ImageDescription",             "Image Description",                "A character string giving the title of the image."),
    TagInfo(0x010f, "Make",                         "Manufacturer",                     "The manufacturer of the recording equipment."),
    TagInfo(0x0110, "Model",                        "Model",                            "The model name or model number of the equipment."),
    TagInfo(0x0111, "StripOffsets",                 "Strip Offsets",                    "For each strip, the byte offset of that strip."),
    TagInfo(0x0112, "Orientation",                  "Orientation",                      "The image orientation viewed in terms of rows and columns."),
    TagInfo(0x0115, "SamplesPerPixel",              "Samples per Pixel",                "The number of components per pixel."),
    TagInfo(0x0116, "RowsPerStrip",                 "Rows per Strip",                   "The number of rows per strip."),
    TagInfo(0x0117, "StripByteCounts",              "Strip Byte Count",                 "The total number of bytes in each strip."),
    TagInfo(0x011a, "XResolution",                  "X-Resolution",                     "The number of pixels per <ResolutionUnit> in the <ImageWidth> direction. "),
    TagInfo(0x011b, "YResolution",                  "Y-Resolution",                     "The number of pixels per <ResolutionUnit> in the <ImageLength> direction."),
    TagInfo(0x011c, "PlanarConfiguration",          "Planar Configuration",             "Indicates whether pixel components are recorded in a chunky or planar format."),
    TagInfo(0x0122, "GrayResponseUnit",             "Gray Response Unit",               "The precision of the information contained in the GrayResponseCurve."),
    TagInfo(0x0123, "GrayResponseCurve",            "Gray Response Curve",              "For grayscale data, the optical density of each possible pixel value."),
    TagInfo(0x0124, "T4Options",                    "T4 Options",                       "T.4-encoding options."),
    TagInfo(0x0125, "T6Options",                    "T6 Options",                       "T.6-encoding options."),
    TagInfo(0x0128, "ResolutionUnit",               "Resolution Unit",                  "The unit for measuring <XResolution> and <YResolution>."),
    TagInfo(0x0129, "PageNumber",                   "Page Number",                      "The page number of the page from which this image was scanned."),
    TagInfo(0x012d, "TransferFunction",             "Transfer Function",                "A transfer function for the image, described in tabular style. "),
    TagInfo(0x0131, "Software",                     "Software",                         "This tag records the name and version of the software or firmware of the camera or image input device used to generate the image."),
    TagInfo(0x0132, "DateTime",                     "Date and Time",                    "The date and time of image creation. "),
    TagInfo(0x013b, "Artist",                       "Artist",                           "This tag records the name of the camera owner, photographer or image creator. "),
    TagInfo(0x013c, "HostComputer",                 "Host Computer",                    "This tag records information about the host computer used to generate the image."),
    TagInfo(0x013d, "Predictor",                    "Predictor",                        "A predictor is a mathematical operator that is applied to the image data before an encoding scheme is applied."),
    TagInfo(0x013e, "WhitePoint",                   "White Point",                      "The chromaticity of the white point of the image."),
    TagInfo(0x013f, "PrimaryChromaticities",        "Primary Chromaticities",           "The chromaticity of the three primary colors of the image. "),
    TagInfo(0x0140, "ColorMap",                     "Color Map",                        "A color map for palette color images. "),
    TagInfo(0x0141, "HalftoneHints",                "Halftone Hints",                   "The purpose of the HalftoneHints field is to convey to the halftone function the range of gray levels within a colorimetrically-specified image that should retain tonal detail."),
    TagInfo(0x0142, "TileWidth",                    "Tile Width",                       "The tile width in pixels. This is the number of columns in each tile."),
    TagInfo(0x0143, "TileLength",                   "Tile Length",                      "The tile length (height) in pixels. This is the number of rows in each tile."),
    TagInfo(0x0144, "TileOffsets",                  "Tile Offsets",                     "For each tile, the byte offset of that tile, as compressed and stored on disk. "),
    TagInfo(0x0145, "TileByteCounts",               "Tile Byte Counts",                 "For each tile, the number of (compressed) bytes in that tile. "),
    TagInfo(0x014a, "SubIFDs",                      "SubIFD Offsets",                   "Defined by Adobe Corporation to enable TIFF Trees within a TIFF file."),
    TagInfo(0x014c, "InkSet",                       "Ink Set",                          "The set of inks used in a separated (PhotometricInterpretation=5) image."),
    TagInfo(0x014d, "InkNames",                     "Ink Names",                        "The name of each ink used in a separated (PhotometricInterpretation=5) image."),
    TagInfo(0x014e, "NumberOfInks",                 "Number Of Inks",                   "The number of inks. Usually equal to SamplesPerPixel, unless there are extra samples."),
    TagInfo(0x0150, "DotRange",                     "Dot Range",                        "The component values that correspond to a 0% dot and 100% dot."),
    TagInfo(0x0151, "TargetPrinter",                "Target Printer",                   "A description of the printing environment for which this separation is intended."),
    TagInfo(0x0152, "ExtraSamples",                 "Extra Samples",                    "Specifies that each pixel has m extra components whose interpretation is defined by one of the values listed below."),
    TagInfo(0x0153, "SampleFormat",                 "Sample Format",                    "This field specifies how to interpret each data sample in a pixel."),
    TagInfo(0x0154, "SMinSampleValue",              "SMin Sample Value",                "This field specifies the minimum sample value."),
    TagInfo(0x0155, "SMaxSampleValue",              "SMax Sample Value",                "This field specifies the maximum sample value."),
    TagInfo(0x0156, "TransferRange",                "Transfer Range",                   "Expands the range of the TransferFunction"),
    TagInfo(0x0157, "ClipPath",                     "Clip Path",                        "A TIFF ClipPath is intended to mirror the essentials of PostScript's path creation functionality."),
    TagInfo(0x0158, "XClipPathUnits",               "X Clip Path Units",                "The number of units that span the width of the image, in terms of integer ClipPath coordinates."),
    TagInfo(0x0159, "YClipPathUnits",               "Y Clip Path Units",                "The number of units that span the height of the image, in terms of integer ClipPath coordinates."),
    TagInfo(0x015a, "Indexed",                      "Indexed",                          "Indexed images are images where the 'pixels' do not represent color values, but rather an index (usually 8-bit) into a separate color table, the ColorMap."),
    TagInfo(0x015b, "JPEGTables",                   "JPEG tables",                      "This optional tag may be used to encode the JPEG quantization and Huffman tables for subsequent use by the JPEG decompression process."),
    TagInfo(0x015F, "OPIProxy",                     "OPI Proxy",                        "OPIProxy gives information concerning whether this image is a low-resolution proxy of a high-resolution image (Adobe OPI)."),
    TagInfo(0x0200, "JPEGProc",                     "JPEG Process",                     "This field indicates the process used to produce the compressed data"),
    TagInfo(0x0201, "JPEGInterchangeFormat",        "JPEG Interchange Format",          "The offset to the start byte (SOI) of JPEG compressed thumbnail data."),
    TagInfo(0x0202, "JPEGInterchangeFormatLength",  "JPEG Interchange Format Length",   "The number of bytes of JPEG compressed thumbnail data. "),
    TagInfo(0x0203, "JPEGRestartInterval",          "JPEG Restart Interval",            "This Field indicates the length of the restart interval used in the compressed image data."),
    TagInfo(0x0205, "JPEGLosslessPredictors",       "JPEG Lossless Predictors",         "This Field points to a list of lossless predictor-selection values, one per component."),
    TagInfo(0x0206, "JPEGPointTransforms",          "JPEG Point Transforms",            "This Field points to a list of point transform values, one per component."),
    TagInfo(0x0207, "JPEGQTables",                  "JPEG Q-Tables",                    "This Field points to a list of offsets to the quantization tables, one per component."),
    TagInfo(0x0208, "JPEGDCTables",                 "JPEG DC-Tables",                   "This Field points to a list of offsets to the DC Huffman tables or the lossless Huffman tables, one per component."),
    TagInfo(0x0209, "JPEGACTables",                 "JPEG AC-Tables",                   "This Field points to a list of offsets to the Huffman AC tables, one per component."),
    TagInfo(0x0211, "YCbCrCoefficients",            "YCbCr Coefficients",               "The matrix coefficients for transformation from RGB to YCbCr image data."),
    TagInfo(0x0212, "YCbCrSubSampling",             "YCbCr Sub-Sampling",               "The sampling ratio of chrominance components in relation to the luminance component. "),
    TagInfo(0x0213, "YCbCrPositioning",             "YCbCr Positioning",                "The position of chrominance components in relation to the luminance component. "),
    TagInfo(0x0214, "ReferenceBlackWhite",          "Reference Black/White",            "The reference black point value and reference white point value. "),
    TagInfo(0x02bc, "XMLPacket",                    "XML Packet",                       "XMP Metadata (Adobe technote 9-14-02)"),
    TagInfo(0x4746, "Rating",                       "Windows Rating",                   "Rating tag used by Windows"),
    TagInfo(0x4749, "RatingPercent",                "Windows Rating Percent",           "Rating tag used by Windows, value in percent"),
    TagInfo(0x800d, "ImageID",                      "Image ID",                         "ImageID is the full pathname of the original, high-resolution image, or any other identifying string that uniquely identifies the original image (Adobe OPI)."),
    TagInfo(0x828d, "CFARepeatPatternDim",          "CFA Repeat Pattern Dimension",     "Contains two values representing the minimum rows and columns to define the repeating patterns of the color filter array"),
    TagInfo(0x828e, "CFAPattern",                   "CFA Pattern",                      "Indicates the color filter array (CFA) geometric pattern of the image sensor when a one-chip color area sensor is used."),
    TagInfo(0x828f, "BatteryLevel",                 "Battery Level",                    "Contains a value of the battery level as a fraction or string"),
    TagInfo(0x8298, "Copyright",                    "Copyright",                        "Copyright information." ),
    TagInfo(0x829a, "ExposureTime",                 "Exposure Time",                    "Exposure time, given in seconds."),
    TagInfo(0x829d, "FNumber",                      "FNumber",                          "The F number."),
    TagInfo(0x83bb, "IPTCNAA",                      "IPTC/NAA",                         "Contains an IPTC/NAA record"),
    TagInfo(0x8649, "ImageResources",               "Image Resources Block",            "Contains information embedded by the Adobe Photoshop application"),
    TagInfo(0x8769, "ExifTag",                      "Exif IFD Pointer",                "A pointer to the Exif IFD."),
    TagInfo(0x8773, "InterColorProfile",            "Inter Color Profile",              "Contains an InterColor Consortium (ICC) format color space characterization/profile"),
    TagInfo(0x8822, "ExposureProgram",              "Exposure Program",                 "The class of the program used by the camera to set exposure when the picture is taken."),
    TagInfo(0x8824, "SpectralSensitivity",          "Spectral Sensitivity",             "Indicates the spectral sensitivity of each channel of the camera used."),
    TagInfo(0x8825, "GPSTag",                       "GPS Info IFD Pointer",             "A pointer to the GPS Info IFD."),
    TagInfo(0x8827, "ISOSpeedRatings",              "ISO Speed Ratings",                "Indicates the ISO Speed and ISO Latitude of the camera or input device as specified in ISO 12232."),
    TagInfo(0x8828, "OECF",                         "OECF",                             "Indicates the Opto-Electric Conversion Function (OECF) specified in ISO 14524."),
    TagInfo(0x8829, "Interlace",                    "Interlace",                        "Indicates the field number of multifield images."),
    TagInfo(0x882a, "TimeZoneOffset",               "Time Zone Offset",                 "This optional tag encodes the time zone of the camera clock (relative to Greenwich Mean Time) used to create the DataTimeOriginal tag-value when the picture was taken."),
    TagInfo(0x882b, "SelfTimerMode",                "Self Timer Mode",                  "Number of seconds image capture was delayed from button press."),
    TagInfo(0x9003, "DateTimeOriginal",             "Date Time Original",               "The date and time when the original image data was generated."),
    TagInfo(0x9102, "CompressedBitsPerPixel",       "Compressed Bits Per Pixel",        "Specific to compressed data; states the compressed bits per pixel."),
    TagInfo(0x9201, "ShutterSpeedValue",            "Shutter Speed",              "Shutter speed."),
    TagInfo(0x9202, "ApertureValue",                "Aperture",                   "The lens aperture."),
    TagInfo(0x9203, "BrightnessValue",              "Brightness Value",                 "The value of brightness."),
    TagInfo(0x9204, "ExposureBiasValue",            "Exposure Bias",              "The exposure bias."),
    TagInfo(0x9205, "MaxApertureValue",             "Max Aperture Value",               "The smallest F number of the lens."),
    TagInfo(0x9206, "SubjectDistance",              "Subject Distance",                 "The distance to the subject, given in meters."),
    TagInfo(0x9207, "MeteringMode",                 "Metering Mode",                    "The metering mode."),
    TagInfo(0x9208, "LightSource",                  "Light Source",                     "The kind of light source."),
    TagInfo(0x9209, "Flash",                        "Flash",                            "Indicates the status of flash when the image was shot."),
    TagInfo(0x920a, "FocalLength",                  "Focal Length",                     "The actual focal length of the lens, in mm."),
    TagInfo(0x920b, "FlashEnergy",                  "Flash Energy",                     "Amount of flash energy (BCPS)."),
    TagInfo(0x920c, "SpatialFrequencyResponse",     "Spatial Frequency Response",       "SFR of the camera."),
    TagInfo(0x920d, "Noise",                        "Noise",                            "Noise measurement values."),
    TagInfo(0x920e, "FocalPlaneXResolution",        "Focal Plane X Resolution",         "Number of pixels per FocalPlaneResolutionUnit (37392) in ImageWidth direction for main image."),
    TagInfo(0x920f, "FocalPlaneYResolution",        "Focal Plane Y Resolution",         "Number of pixels per FocalPlaneResolutionUnit (37392) in ImageLength direction for main image."),
    TagInfo(0x9210, "FocalPlaneResolutionUnit",     "Focal Plane Resolution Unit",      "Unit of measurement for FocalPlaneXResolution(37390) and FocalPlaneYResolution(37391)."),
    TagInfo(0x9211, "ImageNumber",                  "Image Number",                     "Number assigned to an image, e.g., in a chained image burst."),
    TagInfo(0x9212, "SecurityClassification",       "Security Classification",          "Security classification assigned to the image."),
    TagInfo(0x9213, "ImageHistory",                 "Image History",                    "Record of what has been done to the image."),
    TagInfo(0x9214, "SubjectLocation",              "Subject Location",                 "Indicates the location and area of the main subject in the overall scene."),
    TagInfo(0x9215, "ExposureIndex",                "Exposure Index",                   "Encodes the camera exposure index setting when image was captured."),
    TagInfo(0x9216, "TIFFEPStandardID",             "TIFF/EP Standard ID",              "Contains four ASCII characters representing the TIFF/EP standard version of a TIFF/EP file."),
    TagInfo(0x9217, "SensingMethod",                "Sensing Method",                   "Type of image sensor."),
    TagInfo(0x9c9b, "XPTitle",                      "Windows Title",                    "Title tag used by Windows"),
    TagInfo(0x9c9c, "XPComment",                    "Windows Comment",                  "Comment tag used by Windows"),
    TagInfo(0x9c9d, "XPAuthor",                     "Windows Author",                   "Author tag used by Windows"),
    TagInfo(0x9c9e, "XPKeywords",                   "Windows Keywords",                 "Keywords tag used by Windows"),
    TagInfo(0x9c9f, "XPSubject",                    "Windows Subject",                  "Subject tag used by Windows"),
    TagInfo(0xc4a5, "PrintImageMatching",           "Print Image Matching",             "Print Image Matching,."),
    TagInfo(0xc612, "DNGVersion",                   "DNG version",                      "This tag encodes the DNG four-tier version number."),
    TagInfo(0xc613, "DNGBackwardVersion",     "DNG backward version",
                "This tag specifies the oldest version of the Digital Negative "
               "specification for which a file is compatible. Readers should"
               "not attempt to read a file if this tag specifies a version "
               "number that is higher than the version number of the specification "
               "the reader was based on.  In addition to checking the version tags, "
               "readers should, for all tags, check the types, counts, and values, "
               "to verify it is able to correctly read the file."),
    TagInfo(0xc614, "UniqueCameraModel",     "Unique Camera Model",
                "Defines a unique, non-localized name for the camera model that "
               "created the image in the raw file. This name should include the "
               "manufacturer's name to avoid conflicts, and should not be localized, "
               "even if the camera name itself is localized for different markets "
               "(see LocalizedCameraModel). This string may be used by reader "
               "software to index into per-model preferences and replacement profiles."),
    TagInfo(0xc615, "LocalizedCameraModel",     "Localized Camera Model",
                "Similar to the UniqueCameraModel field, except the name can be "
               "localized for different markets to match the localization of the "
               "camera name."),
    TagInfo(0xc616, "CFAPlaneColor",     "CFA Plane Color",
                "Provides a mapping between the values in the CFAPattern tag and the "
               "plane numbers in LinearRaw space. This is a required tag for non-RGB "
               "CFA images."),
    TagInfo(0xc617, "CFALayout",     "CFA Layout",
                "Describes the spatial layout of the CFA."),
    TagInfo(0xc618, "LinearizationTable",     "Linearization Table",
                "Describes a lookup table that maps stored values into linear values. "
               "This tag is typically used to increase compression ratios by storing "
               "the raw data in a non-linear, more visually uniform space with fewer "
               "total encoding levels. If SamplesPerPixel is not equal to one, this "
               "single table applies to all the samples for each pixel."),
    TagInfo(0xc619, "BlackLevelRepeatDim",     "Black Level Repeat Dim",
                "Specifies repeat pattern size for the BlackLevel tag."),
    TagInfo(0xc61a, "BlackLevel",     "Black Level",
                "Specifies the zero light (a.k.a. thermal black or black current) "
               "encoding level, as a repeating pattern. The origin of this pattern "
               "is the top-left corner of the ActiveArea rectangle. The values are "
               "stored in row-column-sample scan order."),
    TagInfo(0xc61b, "BlackLevelDeltaH",     "Black Level Delta H",
                "If the zero light encoding level is a function of the image column, "
               "BlackLevelDeltaH specifies the difference between the zero light "
               "encoding level for each column and the baseline zero light encoding "
               "level. If SamplesPerPixel is not equal to one, this single table "
               "applies to all the samples for each pixel."),
    TagInfo(0xc61c, "BlackLevelDeltaV",     "Black Level Delta V",
                "If the zero light encoding level is a function of the image row, "
               "this tag specifies the difference between the zero light encoding "
               "level for each row and the baseline zero light encoding level. If "
               "SamplesPerPixel is not equal to one, this single table applies to "
               "all the samples for each pixel."),
    TagInfo(0xc61d, "WhiteLevel",     "White Level",
                "This tag specifies the fully saturated encoding level for the raw "
               "sample values. Saturation is caused either by the sensor itself "
               "becoming highly non-linear in response, or by the camera's analog "
               "to digital converter clipping."),
    TagInfo(0xc61e, "DefaultScale",     "Default Scale",
                "DefaultScale is required for cameras with non-square pixels. It "
               "specifies the default scale factors for each direction to convert "
               "the image to square pixels. Typically these factors are selected "
               "to approximately preserve total pixel count. For CFA images that "
               "use CFALayout equal to 2, 3, 4, or 5, such as the Fujifilm SuperCCD, "
               "these two values should usually differ by a factor of 2.0."),
    TagInfo(0xc61f, "DefaultCropOrigin",     "Default Crop Origin",
                "Raw images often store extra pixels around the edges of the final "
               "image. These extra pixels help prevent interpolation artifacts near "
               "the edges of the final image. DefaultCropOrigin specifies the origin "
               "of the final image area, in raw image coordinates (i.e., before the "
               "DefaultScale has been applied), relative to the top-left corner of "
               "the ActiveArea rectangle."),
    TagInfo(0xc620, "DefaultCropSize",     "Default Crop Size",
                "Raw images often store extra pixels around the edges of the final "
               "image. These extra pixels help prevent interpolation artifacts near "
               "the edges of the final image. DefaultCropSize specifies the size of "
               "the final image area, in raw image coordinates (i.e., before the "
               "DefaultScale has been applied)."),
    TagInfo(0xc621, "ColorMatrix1",     "Color Matrix 1",
                "ColorMatrix1 defines a transformation matrix that converts XYZ "
               "values to reference camera native color space values, under the "
               "first calibration illuminant. The matrix values are stored in row "
               "scan order. The ColorMatrix1 tag is required for all non-monochrome "
               "DNG files."),
    TagInfo(0xc622, "ColorMatrix2",     "Color Matrix 2",
                "ColorMatrix2 defines a transformation matrix that converts XYZ "
               "values to reference camera native color space values, under the "
               "second calibration illuminant. The matrix values are stored in row "
               "scan order."),
    TagInfo(0xc623, "CameraCalibration1",     "Camera Calibration 1",
                "CameraCalibration1 defines a calibration matrix that transforms "
               "reference camera native space values to individual camera native "
               "space values under the first calibration illuminant. The matrix is "
               "stored in row scan order. This matrix is stored separately from the "
               "matrix specified by the ColorMatrix1 tag to allow raw converters to "
               "swap in replacement color matrices based on UniqueCameraModel tag, "
               "while still taking advantage of any per-individual camera calibration "
               "performed by the camera manufacturer."),
    TagInfo(0xc624, "CameraCalibration2",     "Camera Calibration 2",
                "CameraCalibration2 defines a calibration matrix that transforms "
               "reference camera native space values to individual camera native "
               "space values under the second calibration illuminant. The matrix is "
               "stored in row scan order. This matrix is stored separately from the "
               "matrix specified by the ColorMatrix2 tag to allow raw converters to "
               "swap in replacement color matrices based on UniqueCameraModel tag, "
               "while still taking advantage of any per-individual camera calibration "
               "performed by the camera manufacturer."),
    TagInfo(0xc625, "ReductionMatrix1",     "Reduction Matrix 1",
                "ReductionMatrix1 defines a dimensionality reduction matrix for use as "
               "the first stage in converting color camera native space values to XYZ "
               "values, under the first calibration illuminant. This tag may only be "
               "used if ColorPlanes is greater than 3. The matrix is stored in row "
               "scan order."),
    TagInfo(0xc626, "ReductionMatrix2",     "Reduction Matrix 2",
                "ReductionMatrix2 defines a dimensionality reduction matrix for use as "
               "the first stage in converting color camera native space values to XYZ "
               "values, under the second calibration illuminant. This tag may only be "
               "used if ColorPlanes is greater than 3. The matrix is stored in row "
               "scan order."),
    TagInfo(0xc627, "AnalogBalance",     "Analog Balance",
                "Normally the stored raw values are not white balanced, since any "
               "digital white balancing will reduce the dynamic range of the final "
               "image if the user decides to later adjust the white balance; "
               "however, if camera hardware is capable of white balancing the color "
               "channels before the signal is digitized, it can improve the dynamic "
               "range of the final image. AnalogBalance defines the gain, either "
               "analog (recommended) or digital (not recommended) that has been "
               "applied the stored raw values."),
    TagInfo(0xc628, "AsShotNeutral",     "As Shot Neutral",
                "Specifies the selected white balance at time of capture, encoded as "
               "the coordinates of a perfectly neutral color in linear reference "
               "space values. The inclusion of this tag precludes the inclusion of "
               "the AsShotWhiteXY tag."),
    TagInfo(0xc629, "AsShotWhiteXY",     "As Shot White XY",
                "Specifies the selected white balance at time of capture, encoded as "
               "x-y chromaticity coordinates. The inclusion of this tag precludes "
               "the inclusion of the AsShotNeutral tag."),
    TagInfo(0xc62a, "BaselineExposure",     "Baseline Exposure",
                "Camera models vary in the trade-off they make between highlight "
               "headroom and shadow noise. Some leave a significant amount of "
               "highlight headroom during a normal exposure. This allows significant "
               "negative exposure compensation to be applied during raw conversion, "
               "but also means normal exposures will contain more shadow noise. Other "
               "models leave less headroom during normal exposures. This allows for "
               "less negative exposure compensation, but results in lower shadow "
               "noise for normal exposures. Because of these differences, a raw "
               "converter needs to vary the zero point of its exposure compensation "
               "control from model to model. BaselineExposure specifies by how much "
               "(in EV units) to move the zero point. Positive values result in "
               "brighter default results, while negative values result in darker "
               "default results."),
    TagInfo(0xc62b, "BaselineNoise",     "Baseline Noise",
                "Specifies the relative noise level of the camera model at a baseline "
               "ISO value of 100, compared to a reference camera model. Since noise "
               "levels tend to vary approximately with the square root of the ISO "
               "value, a raw converter can use this value, combined with the current "
               "ISO, to estimate the relative noise level of the current image."),
    TagInfo(0xc62c, "BaselineSharpness",     "Baseline Sharpness",
                "Specifies the relative amount of sharpening required for this camera "
               "model, compared to a reference camera model. Camera models vary in "
               "the strengths of their anti-aliasing filters. Cameras with weak or "
               "no filters require less sharpening than cameras with strong "
               "anti-aliasing filters."),
    TagInfo(0xc62d, "BayerGreenSplit",     "Bayer Green Split",
                "Only applies to CFA images using a Bayer pattern filter array. This "
               "tag specifies, in arbitrary units, how closely the values of the "
               "green pixels in the blue/green rows track the values of the green "
               "pixels in the red/green rows. A value of zero means the two kinds "
               "of green pixels track closely, while a non-zero value means they "
               "sometimes diverge. The useful range for this tag is from 0 (no "
               "divergence) to about 5000 (quite large divergence)."),
    TagInfo(0xc62e, "LinearResponseLimit",     "Linear Response Limit",
                "Some sensors have an unpredictable non-linearity in their response "
               "as they near the upper limit of their encoding range. This "
               "non-linearity results in color shifts in the highlight areas of the "
               "resulting image unless the raw converter compensates for this effect. "
               "LinearResponseLimit specifies the fraction of the encoding range "
               "above which the response may become significantly non-linear."),
    TagInfo(0xc62f, "CameraSerialNumber",     "Camera Serial Number",
                "CameraSerialNumber contains the serial number of the camera or camera "
               "body that captured the image."),
    TagInfo(0xc630, "LensInfo",     "Lens Info",
                "Contains information about the lens that captured the image. If the "
               "minimum f-stops are unknown, they should be encoded as 0/0."),
    TagInfo(0xc631, "ChromaBlurRadius",     "Chroma Blur Radius",
                "ChromaBlurRadius provides a hint to the DNG reader about how much "
               "chroma blur should be applied to the image. If this tag is omitted, "
               "the reader will use its default amount of chroma blurring. "
               "Normally this tag is only included for non-CFA images, since the "
               "amount of chroma blur required for mosaic images is highly dependent "
               "on the de-mosaic algorithm, in which case the DNG reader's default "
               "value is likely optimized for its particular de-mosaic algorithm."),
    TagInfo(0xc632, "AntiAliasStrength",     "Anti Alias Strength",
                "Provides a hint to the DNG reader about how strong the camera's "
               "anti-alias filter is. A value of 0.0 means no anti-alias filter "
               "(i.e., the camera is prone to aliasing artifacts with some subjects), "
               "while a value of 1.0 means a strong anti-alias filter (i.e., the "
               "camera almost never has aliasing artifacts)."),
    TagInfo(0xc633, "ShadowScale",     "Shadow Scale",
                "This tag is used by Adobe Camera Raw to control the sensitivity of "
               "its 'Shadows' slider."),
    TagInfo(0xc634, "DNGPrivateData",     "DNG Private Data",
                "Provides a way for camera manufacturers to store private data in the "
               "DNG file for use by their own raw converters, and to have that data "
               "preserved by programs that edit DNG files."),
    TagInfo(0xc635, "MakerNoteSafety",     "MakerNote Safety",
                "MakerNoteSafety lets the DNG reader know whether the EXIF MakerNote "
               "tag is safe to preserve along with the rest of the EXIF data. File "
               "browsers and other image management software processing an image "
               "with a preserved MakerNote should be aware that any thumbnail "
               "image embedded in the MakerNote may be stale, and may not reflect "
               "the current state of the full size image."),
    TagInfo(0xc65a, "CalibrationIlluminant1",     "Calibration Illuminant 1",
                "The illuminant used for the first set of color calibration tags "
               "(ColorMatrix1, CameraCalibration1, ReductionMatrix1). The legal "
               "values for this tag are the same as the legal values for the "
               "LightSource EXIF tag."),
    TagInfo(0xc65b, "CalibrationIlluminant2",     "Calibration Illuminant 2",
                "The illuminant used for an optional second set of color calibration "
               "tags (ColorMatrix2, CameraCalibration2, ReductionMatrix2). The legal "
               "values for this tag are the same as the legal values for the "
               "CalibrationIlluminant1 tag; however, if both are included, neither "
               "is allowed to have a value of 0 (unknown)."),
    TagInfo(0xc65c, "BestQualityScale",     "Best Quality Scale",
                "For some cameras, the best possible image quality is not achieved "
               "by preserving the total pixel count during conversion. For example, "
               "Fujifilm SuperCCD images have maximum detail when their total pixel "
               "count is doubled. This tag specifies the amount by which the values "
               "of the DefaultScale tag need to be multiplied to achieve the best "
               "quality image size."),
    TagInfo(0xc65d, "RawDataUniqueID",     "Raw Data Unique ID",
                "This tag contains a 16-byte unique identifier for the raw image data "
               "in the DNG file. DNG readers can use this tag to recognize a "
               "particular raw image, even if the file's name or the metadata "
               "contained in the file has been changed. If a DNG writer creates such "
               "an identifier, it should do so using an algorithm that will ensure "
               "that it is very unlikely two different images will end up having the "
               "same identifier."),
    TagInfo(0xc68b, "OriginalRawFileName",     "Original Raw File Name",
                "If the DNG file was converted from a non-DNG raw file, then this tag "
               "contains the file name of that original raw file."),
    TagInfo(0xc68c, "OriginalRawFileData",     "Original Raw File Data",
                "If the DNG file was converted from a non-DNG raw file, then this tag "
               "contains the compressed contents of that original raw file. The "
               "contents of this tag always use the big-endian byte order. The tag "
               "contains a sequence of data blocks. Future versions of the DNG "
               "specification may define additional data blocks, so DNG readers "
               "should ignore extra bytes when parsing this tag. DNG readers should "
               "also detect the case where data blocks are missing from the end of "
               "the sequence, and should assume a default value for all the missing "
               "blocks. There are no padding or alignment bytes between data blocks."),
    TagInfo(0xc68d, "ActiveArea",     "Active Area",
                "This rectangle defines the active (non-masked) pixels of the sensor. "
               "The order of the rectangle coordinates is: top, left, bottom, right."),
    TagInfo(0xc68e, "MaskedAreas",     "Masked Areas",
                "This tag contains a list of non-overlapping rectangle coordinates of "
               "fully masked pixels, which can be optionally used by DNG readers "
               "to measure the black encoding level. The order of each rectangle's "
               "coordinates is: top, left, bottom, right. If the raw image data has "
               "already had its black encoding level subtracted, then this tag should "
               "not be used, since the masked pixels are no longer useful."),
    TagInfo(0xc68f, "AsShotICCProfile",     "As-Shot ICC Profile",
                "This tag contains an ICC profile that, in conjunction with the "
               "AsShotPreProfileMatrix tag, provides the camera manufacturer with a "
               "way to specify a default color rendering from camera color space "
               "coordinates (linear reference values) into the ICC profile connection "
               "space. The ICC profile connection space is an output referred "
               "colorimetric space, whereas the other color calibration tags in DNG "
               "specify a conversion into a scene referred colorimetric space. This "
               "means that the rendering in this profile should include any desired "
               "tone and gamut mapping needed to convert between scene referred "
               "values and output referred values."),
    TagInfo(0xc690, "AsShotPreProfileMatrix",     "As-Shot Pre-Profile Matrix",
                "This tag is used in conjunction with the AsShotICCProfile tag. It "
               "specifies a matrix that should be applied to the camera color space "
               "coordinates before processing the values through the ICC profile "
               "specified in the AsShotICCProfile tag. The matrix is stored in the "
               "row scan order. If ColorPlanes is greater than three, then this "
               "matrix can (but is not required to) reduce the dimensionality of the "
               "color data down to three components, in which case the AsShotICCProfile "
               "should have three rather than ColorPlanes input components."),
    TagInfo(0xc691, "CurrentICCProfile",     "Current ICC Profile",
                "This tag is used in conjunction with the CurrentPreProfileMatrix tag. "
               "The CurrentICCProfile and CurrentPreProfileMatrix tags have the same "
               "purpose and usage as the AsShotICCProfile and AsShotPreProfileMatrix "
               "tag pair, except they are for use by raw file editors rather than "
               "camera manufacturers."),
    TagInfo(0xc692, "CurrentPreProfileMatrix",     "Current Pre-Profile Matrix",
                "This tag is used in conjunction with the CurrentICCProfile tag. "
               "The CurrentICCProfile and CurrentPreProfileMatrix tags have the same "
               "purpose and usage as the AsShotICCProfile and AsShotPreProfileMatrix "
               "tag pair, except they are for use by raw file editors rather than "
               "camera manufacturers."),
    TagInfo(0xc6bf, "ColorimetricReference",     "Colorimetric Reference",
                "The DNG color model documents a transform between camera colors and "
            "CIE XYZ values. This tag describes the colorimetric reference for the "
            "CIE XYZ values. 0 = The XYZ values are scene-referred. 1 = The XYZ values "
            "are output-referred, using the ICC profile perceptual dynamic range. This "
            "tag allows output-referred data to be stored in DNG files and still processed "
            "correctly by DNG readers."),
    TagInfo(0xc6f3, "CameraCalibrationSignature",     "Camera Calibration Signature",
                "A UTF-8 encoded string associated with the CameraCalibration1 and "
            "CameraCalibration2 tags. The CameraCalibration1 and CameraCalibration2 tags "
            "should only be used in the DNG color transform if the string stored in the "
            "CameraCalibrationSignature tag exactly matches the string stored in the "
            "ProfileCalibrationSignature tag for the selected camera profile."),
    TagInfo(0xc6f4, "ProfileCalibrationSignature",     "Profile Calibration Signature",
                "A UTF-8 encoded string associated with the camera profile tags. The "
            "CameraCalibration1 and CameraCalibration2 tags should only be used in the "
            "DNG color transfer if the string stored in the CameraCalibrationSignature "
            "tag exactly matches the string stored in the ProfileCalibrationSignature tag "
            "for the selected camera profile."),
    TagInfo(0xc6f6, "AsShotProfileName",     "As Shot Profile Name",
                "A UTF-8 encoded string containing the name of the \"as shot\" camera "
            "profile, if any."),
    TagInfo(0xc6f7, "NoiseReductionApplied",     "Noise Reduction Applied",
                "This tag indicates how much noise reduction has been applied to the raw "
            "data on a scale of 0.0 to 1.0. A 0.0 value indicates that no noise reduction "
            "has been applied. A 1.0 value indicates that the \"ideal\" amount of noise "
            "reduction has been applied, i.e. that the DNG reader should not apply "
            "additional noise reduction by default. A value of 0/0 indicates that this "
            "parameter is unknown."),
    TagInfo(0xc6f8, "ProfileName",     "Profile Name",
                "A UTF-8 encoded string containing the name of the camera profile. This "
            "tag is optional if there is only a single camera profile stored in the file "
            "but is required for all camera profiles if there is more than one camera "
            "profile stored in the file."),
    TagInfo(0xc6f9, "ProfileHueSatMapDims",     "Profile Hue Sat Map Dims",
                "This tag specifies the number of input samples in each dimension of the "
            "hue/saturation/value mapping tables. The data for these tables are stored "
            "in ProfileHueSatMapData1 and ProfileHueSatMapData2 tags. The most common "
            "case has ValueDivisions equal to 1, so only hue and saturation are used as "
            "inputs to the mapping table."),
    TagInfo(0xc6fa, "ProfileHueSatMapData1",     "Profile Hue Sat Map Data 1",
                "This tag contains the data for the first hue/saturation/value mapping "
            "table. Each entry of the table contains three 32-bit IEEE floating-point "
            "values. The first entry is hue shift in degrees; the second entry is "
            "saturation scale factor; and the third entry is a value scale factor. The "
            "table entries are stored in the tag in nested loop order, with the value "
            "divisions in the outer loop, the hue divisions in the middle loop, and the "
            "saturation divisions in the inner loop. All zero input saturation entries "
            "are required to have a value scale factor of 1.0."),
    TagInfo(0xc6fb, "ProfileHueSatMapData2",     "Profile Hue Sat Map Data 2",
                "This tag contains the data for the second hue/saturation/value mapping "
            "table. Each entry of the table contains three 32-bit IEEE floating-point "
            "values. The first entry is hue shift in degrees; the second entry is a "
            "saturation scale factor; and the third entry is a value scale factor. The "
            "table entries are stored in the tag in nested loop order, with the value "
            "divisions in the outer loop, the hue divisions in the middle loop, and the "
            "saturation divisions in the inner loop. All zero input saturation entries "
            "are required to have a value scale factor of 1.0."),
    TagInfo(0xc6fc, "ProfileToneCurve",     "Profile Tone Curve",
                "This tag contains a default tone curve that can be applied while "
            "processing the image as a starting point for user adjustments. The curve "
            "is specified as a list of 32-bit IEEE floating-point value pairs in linear "
            "gamma. Each sample has an input value in the range of 0.0 to 1.0, and an "
            "output value in the range of 0.0 to 1.0. The first sample is required to be "
            "(0.0, 0.0), and the last sample is required to be (1.0, 1.0). Interpolated "
            "the curve using a cubic spline."),
    TagInfo(0xc6fd, "ProfileEmbedPolicy",     "Profile Embed Policy",
                "This tag contains information about the usage rules for the associated "
            "camera profile."),
    TagInfo(0xc6fe, "ProfileCopyright",     "Profile Copyright",
                "A UTF-8 encoded string containing the copyright information for the "
            "camera profile. This string always should be preserved along with the other "
            "camera profile tags."),
    TagInfo(0xc714, "ForwardMatrix1",     "Forward Matrix 1",
                "This tag defines a matrix that maps white balanced camera colors to XYZ "
            "D50 colors."),
    TagInfo(0xc715, "ForwardMatrix2",     "Forward Matrix 2",
                "This tag defines a matrix that maps white balanced camera colors to XYZ "
            "D50 colors."),
    TagInfo(0xc716, "PreviewApplicationName",     "Preview Application Name",
                "A UTF-8 encoded string containing the name of the application that "
            "created the preview stored in the IFD."),
    TagInfo(0xc717, "PreviewApplicationVersion",     "Preview Application Version",
                "A UTF-8 encoded string containing the version number of the application "
            "that created the preview stored in the IFD."),
    TagInfo(0xc718, "PreviewSettingsName",     "Preview Settings Name",
                "A UTF-8 encoded string containing the name of the conversion settings "
            "(for example, snapshot name) used for the preview stored in the IFD."),
    TagInfo(0xc719, "PreviewSettingsDigest",     "Preview Settings Digest",
                "A unique ID of the conversion settings (for example, MD5 digest) used "
            "to render the preview stored in the IFD."),
    TagInfo(0xc71a, "PreviewColorSpace",     "Preview Color Space",
                "This tag specifies the color space in which the rendered preview in this "
            "IFD is stored. The default value for this tag is sRGB for color previews "
            "and Gray Gamma 2.2 for monochrome previews."),
    TagInfo(0xc71b, "PreviewDateTime",     "Preview Date Time",
                "This tag is an ASCII string containing the name of the date/time at which "
            "the preview stored in the IFD was rendered. The date/time is encoded using "
            "ISO 8601 format."),
    TagInfo(0xc71c, "RawImageDigest",     "Raw Image Digest",
                "This tag is an MD5 digest of the raw image data. All pixels in the image "
            "are processed in row-scan order. Each pixel is zero padded to 16 or 32 bits "
            "deep (16-bit for data less than or equal to 16 bits deep, 32-bit otherwise). "
            "The data for each pixel is processed in little-endian byte order."),
    TagInfo(0xc71d, "OriginalRawFileDigest",     "Original Raw File Digest",
                "This tag is an MD5 digest of the data stored in the OriginalRawFileData "
            "tag."),
    TagInfo(0xc71e, "SubTileBlockSize",     "Sub Tile Block Size",
                "Normally, the pixels within a tile are stored in simple row-scan order. "
            "This tag specifies that the pixels within a tile should be grouped first "
            "into rectangular blocks of the specified size. These blocks are stored in "
            "row-scan order. Within each block, the pixels are stored in row-scan order. "
            "The use of a non-default value for this tag requires setting the "
            "DNGBackwardVersion tag to at least 1.2.0.0."),
    TagInfo(0xc71f, "RowInterleaveFactor",     "Row Interleave Factor",
                "This tag specifies that rows of the image are stored in interleaved "
            "order. The value of the tag specifies the number of interleaved fields. "
            "The use of a non-default value for this tag requires setting the "
            "DNGBackwardVersion tag to at least 1.2.0.0."),
    TagInfo(0xc725, "ProfileLookTableDims",     "Profile Look Table Dims",
                "This tag specifies the number of input samples in each dimension of a "
            "default \"look\" table. The data for this table is stored in the "
            "ProfileLookTableData tag."),
    TagInfo(0xc726, "ProfileLookTableData",     "Profile Look Table Data",
                "This tag contains a default \"look\" table that can be applied while "
            "processing the image as a starting point for user adjustment. This table "
            "uses the same format as the tables stored in the ProfileHueSatMapData1 "
            "and ProfileHueSatMapData2 tags, and is applied in the same color space. "
            "However, it should be applied later in the processing pipe, after any "
            "exposure compensation and/or fill light stages, but before any tone curve "
            "stage. Each entry of the table contains three 32-bit IEEE floating-point "
            "values. The first entry is hue shift in degrees, the second entry is a "
            "saturation scale factor, and the third entry is a value scale factor. "
            "The table entries are stored in the tag in nested loop order, with the "
            "value divisions in the outer loop, the hue divisions in the middle loop, "
            "and the saturation divisions in the inner loop. All zero input saturation "
            "entries are required to have a value scale factor of 1.0."),
    TagInfo(0xc740, "OpcodeList1",     "Opcode List 1",
                "Specifies the list of opcodes that should be applied to the raw image, "
            "as read directly from the file."),
    TagInfo(0xc741, "OpcodeList2",     "Opcode List 2",
                "Specifies the list of opcodes that should be applied to the raw image, "
            "just after it has been mapped to linear reference values."),
    TagInfo(0xc74e, "OpcodeList3",     "Opcode List 3",
                "Specifies the list of opcodes that should be applied to the raw image, "
            "just after it has been demosaiced."),
    TagInfo(0xc761, "NoiseProfile",     "Noise Profile",
                "NoiseProfile describes the amount of noise in a raw image. Specifically, "
            "this tag models the amount of signal-dependent photon (shot) noise and "
            "signal-independent sensor readout noise, two common sources of noise in "
            "raw images. The model assumes that the noise is white and spatially "
            "independent, ignoring fixed pattern effects and other sources of noise (e.g., "
            "pixel response non-uniformity, spatially-dependent thermal effects, etc.)."),

    ////////////////////////////////////////
    // http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/cinemadng/pdfs/CinemaDNG_Format_Specification_v1_1.pdf
    TagInfo(0xc763, "TimeCodes",     "TimeCodes",
                "The optional TimeCodes tag shall contain an ordered array of time codes. "
            "All time codes shall be 8 bytes long and in binary format. The tag may "
            "contain from 1 to 10 time codes. When the tag contains more than one time "
            "code, the first one shall be the default time code. This specification "
            "does not prescribe how to use multiple time codes. "
            "Each time code shall be as defined for the 8-byte time code structure in "
            "SMPTE 331M-2004, Section 8.3. See also SMPTE 12-1-2008 and SMPTE 309-1999."),
    TagInfo(0xc764, "FrameRate",     "FrameRate",
                "The optional FrameRate tag shall specify the video frame "
               "rate in number of image frames per second, expressed as a "
               "signed rational number. The numerator shall be non-negative "
               "and the denominator shall be positive. This field value is "
               "identical to the sample rate field in SMPTE 377-1-2009."),
    TagInfo(0xc772, "TStop",     "TStop",
                "The optional TStop tag shall specify the T-stop of the "
            "actual lens, expressed as an unsigned rational number. "
            "T-stop is also known as T-number or the photometric "
            "aperture of the lens. (F-number is the geometric aperture "
            "of the lens.) When the exact value is known, the T-stop "
            "shall be specified using a single number. Alternately, "
            "two numbers shall be used to indicate a T-stop range, "
            "in which case the first number shall be the minimum "
            "T-stop and the second number shall be the maximum T-stop."),
    TagInfo(0xc789, "ReelName",     "ReelName",
                "The optional ReelName tag shall specify a name for a "
            "sequence of images, where each image in the sequence has "
            "a unique image identifier (including but not limited to file "
            "name, frame number, date time, time code)."),
    TagInfo(0xc7a1, "CameraLabel",     "CameraLabel",
                "The optional CameraLabel tag shall specify a text label "
            "for how the camera is used or assigned in this clip. "
            "This tag is similar to CameraLabel in XMP."),

///< Exif.Photo
    TagInfo(0x829a, "ExposureTime", "Exposure Time","Exposure time, given in seconds (sec)."),
     TagInfo(0x829d, "FNumber", "FNumber", "The F number."),
     TagInfo(0x8822, "ExposureProgram", "Exposure Program", "The class of the program used by the camera to set exposure when the picture is taken."),
     TagInfo(0x8824, "SpectralSensitivity", "Spectral Sensitivity",
             "Indicates the spectral sensitivity of each channel of the "
             "camera used. The tag value is an ASCII string compatible "
             "with the standard developed by the ASTM Technical Committee."),
     TagInfo(0x8827, "ISOSpeedRatings", "ISO Speed Ratings",
             "Indicates the ISO Speed and ISO Latitude of the camera or "
             "input device as specified in ISO 12232."),
     TagInfo(0x8828, "OECF", "Opto-Electoric Conversion Function",
             "Indicates the Opto-Electoric Conversion Function (OECF) "
             "specified in ISO 14524. <OECF> is the relationship between "
             "the camera optical input and the image values."),
     TagInfo(0x8830, "SensitivityType", "Sensitivity Type",
             "The SensitivityType tag indicates which one of the parameters of "
             "ISO12232 is the PhotographicSensitivity tag. Although it is an optional tag, "
             "it should be recorded when a PhotographicSensitivity tag is recorded. "
             "Value = 4, 5, 6, or 7 may be used in case that the values of plural "
             "parameters are the same."),
     TagInfo(0x8831, "StandardOutputSensitivity", "Standard Output Sensitivity",
             "This tag indicates the standard output sensitivity value of a camera or "
             "input device defined in ISO 12232. When recording this tag, the "
             "PhotographicSensitivity and SensitivityType tags shall also be recorded."),
     TagInfo(0x8832, "RecommendedExposureIndex", "Recommended Exposure Index",
             "This tag indicates the recommended exposure index value of a camera or "
             "input device defined in ISO 12232. When recording this tag, the "
             "PhotographicSensitivity and SensitivityType tags shall also be recorded."),
     TagInfo(0x8833, "ISOSpeed", "ISO Speed",
             "This tag indicates the ISO speed value of a camera or input device that "
             "is defined in ISO 12232. When recording this tag, the PhotographicSensitivity "
             "and SensitivityType tags shall also be recorded."),
     TagInfo(0x8834, "ISOSpeedLatitudeyyy", "ISO Speed Latitude yyy",
             "This tag indicates the ISO speed latitude yyy value of a camera or input "
             "device that is defined in ISO 12232. However, this tag shall not be recorded "
             "without ISOSpeed and ISOSpeedLatitudezzz."),
     TagInfo(0x8835, "ISOSpeedLatitudezzz", "ISO Speed Latitude zzz",
             "This tag indicates the ISO speed latitude zzz value of a camera or input "
             "device that is defined in ISO 12232. However, this tag shall not be recorded "
             "without ISOSpeed and ISOSpeedLatitudeyyy."),
     TagInfo(0x9000, "ExifVersion", "Exif Version",
             "The version of this standard supported. Nonexistence of this "
             "field is taken to mean nonconformance to the standard."),
     TagInfo(0x9003, "DateTimeOriginal", "Date and Time (original)",
             "The date and time when the original image data was generated. "
             "For a digital still camera the date and time the picture was taken are recorded."),
     TagInfo(0x9004, "DateTimeDigitized", "Date and Time (digitized)",
             "The date and time when the image was stored as digital data."),
     TagInfo(0x9101, "ComponentsConfiguration", "Components Configuration",
             "Information specific to compressed data. The channels of "
             "each component are arranged in order from the 1st "
             "component to the 4th. For uncompressed data the data "
             "arrangement is given in the <PhotometricInterpretation> tag. "
             "However, since <PhotometricInterpretation> can only "
             "express the order of Y, Cb and Cr, this tag is provided "
             "for cases when compressed data uses components other than "
             "Y, Cb, and Cr and to enable support of other sequences."),
     TagInfo(0x9102, "CompressedBitsPerPixel", "Compressed Bits per Pixel",
             "Information specific to compressed data. The compression mode "
             "used for a compressed image is indicated in unit bits per pixel."),
     TagInfo(0x9201, "ShutterSpeedValue", "Shutter speed",
             "Shutter speed. The unit is the APEX (Additive System of "
             "Photographic Exposure) setting."),
     TagInfo(0x9202, "ApertureValue", "Aperture",
             "The lens aperture. The unit is the APEX value."),
     TagInfo(0x9203, "BrightnessValue", "Brightness",
             "The value of brightness. The unit is the APEX value. "
             "Ordinarily it is given in the range of -99.99 to 99.99."),
     TagInfo(0x9204, "ExposureBiasValue", "Exposure Bias",
             "The exposure bias. The units is the APEX value. Ordinarily "
             "it is given in the range of -99.99 to 99.99."),
     TagInfo(0x9205, "MaxApertureValue", "Max Aperture Value",
             "The smallest F number of the lens. The unit is the APEX value. "
             "Ordinarily it is given in the range of 00.00 to 99.99, "
             "but it is not limited to this range."),
     TagInfo(0x9206, "SubjectDistance", "Subject Distance",
             "The distance to the subject, given in meters."),
     TagInfo(0x9207, "MeteringMode", "Metering Mode",
             "The metering mode."),
     TagInfo(0x9208, "LightSource", "Light Source",
             "The kind of light source."),
     TagInfo(0x9209, "Flash", "Flash",
             "This tag is recorded when an image is taken using a strobe light (flash)."),
     TagInfo(0x920a, "FocalLength", "Focal Length",
             "The actual focal length of the lens, in mm. Conversion is not "
             "made to the focal length of a 35 mm film camera."),
     TagInfo(0x9214, "SubjectArea", "Subject Area",
             "This tag indicates the location and area of the main subject "
             "in the overall scene."),
     TagInfo(0x927c, "MakerNote", "Maker Note",
             "A tag for manufacturers of Exif writers to record any desired "
             "information. The contents are up to the manufacturer."),
     TagInfo(0x9286, "UserComment", "User Comment",
             "A tag for Exif users to write keywords or comments on the image "
             "besides those in <ImageDescription>, and without the "
             "character code limitations of the <ImageDescription> tag."),
     TagInfo(0x9290, "SubSecTime", "Sub-seconds Time",
             "A tag used to record fractions of seconds for the <DateTime> tag."),
     TagInfo(0x9291, "SubSecTimeOriginal", "Sub-seconds Time Original",
             "A tag used to record fractions of seconds for the <DateTimeOriginal> tag."),
     TagInfo(0x9292, "SubSecTimeDigitized", "Sub-seconds Time Digitized",
             "A tag used to record fractions of seconds for the <DateTimeDigitized> tag."),
     TagInfo(0xa000, "FlashpixVersion", "FlashPix Version",
             "The FlashPix format version supported by a FPXR file."),
     TagInfo(0xa001, "ColorSpace", "Color Space",
             "The color space information tag is always "
             "recorded as the color space specifier. Normally sRGB "
             "is used to define the color space based on the PC monitor "
             "conditions and environment. If a color space other than "
             "sRGB is used, Uncalibrated is set. Image data "
             "recorded as Uncalibrated can be treated as sRGB when it is "
             "converted to FlashPix."),
     TagInfo(0xa002, "PixelXDimension", "Pixel X Dimension",
             "Information specific to compressed data. When a "
             "compressed file is recorded, the valid width of the "
             "meaningful image must be recorded in this tag, whether or "
             "not there is padding data or a restart marker. This tag "
             "should not exist in an uncompressed file."),
     TagInfo(0xa003, "PixelYDimension", "Pixel Y Dimension",
             "Information specific to compressed data. When a compressed "
             "file is recorded, the valid height of the meaningful image "
             "must be recorded in this tag, whether or not there is padding "
             "data or a restart marker. This tag should not exist in an "
             "uncompressed file. Since data padding is unnecessary in the vertical "
             "direction, the number of lines recorded in this valid image height tag "
             "will in fact be the same as that recorded in the SOF."),
     TagInfo(0xa004, "RelatedSoundFile", "Related Sound File",
             "This tag is used to record the name of an audio file related "
             "to the image data. The only relational information "
             "recorded here is the Exif audio file name and extension (an "
             "ASCII string consisting of 8 characters + '.' + 3 "
             "characters). The path is not recorded."),
     TagInfo(0xa005, "InteroperabilityTag", "Interoperability IFD Pointer",
             "Interoperability IFD is composed of tags which stores the "
             "information to ensure the Interoperability and pointed "
             "by the following tag located in Exif IFD. "
             "The Interoperability structure of Interoperability IFD is "
             "the same as TIFF defined IFD structure but does not contain the "
             "image data characteristically compared with normal TIFF IFD."),
     TagInfo(0xa20b, "FlashEnergy", "Flash Energy",
             "Indicates the strobe energy at the time the image is "
             "captured, as measured in Beam Candle Power Seconds (BCPS)."),
     TagInfo(0xa20c, "SpatialFrequencyResponse", "Spatial Frequency Response",
             "This tag records the camera or input device spatial frequency "
             "table and SFR values in the direction of image width, "
             "image height, and diagonal direction, as specified in ISO 12233."),
     TagInfo(0xa20e, "FocalPlaneXResolution", "Focal Plane X-Resolution",
             "Indicates the number of pixels in the image width (X) direction "
             "per <FocalPlaneResolutionUnit> on the camera focal plane."),
     TagInfo(0xa20f, "FocalPlaneYResolution", "Focal Plane Y-Resolution",
             "Indicates the number of pixels in the image height (V) direction "
             "per <FocalPlaneResolutionUnit> on the camera focal plane."),
     TagInfo(0xa210, "FocalPlaneResolutionUnit", "Focal Plane Resolution Unit",
             "Indicates the unit for measuring <FocalPlaneXResolution> and "
             "<FocalPlaneYResolution>. This value is the same as the <ResolutionUnit>."),
     TagInfo(0xa214, "SubjectLocation", "Subject Location",
             "Indicates the location of the main subject in the scene. The "
             "value of this tag represents the pixel at the center of the "
             "main subject relative to the left edge, prior to rotation "
             "processing as per the <Rotation> tag. The first value "
             "indicates the X column number and second indicates the Y row number."),
     TagInfo(0xa215, "ExposureIndex", "Exposure index",
             "Indicates the exposure index selected on the camera or "
             "input device at the time the image is captured."),
     TagInfo(0xa217, "SensingMethod", "Sensing Method",
             "Indicates the image sensor type on the camera or input device."),
     TagInfo(0xa300, "FileSource", "File Source",
             "Indicates the image source. If a DSC recorded the image, "
             "this tag value of this tag always be set to 3, indicating "
             "that the image was recorded on a DSC."),
     TagInfo(0xa301, "SceneType", "Scene Type",
             "Indicates the type of scene. If a DSC recorded the image, "
             "this tag value must always be set to 1, indicating that the "
             "image was directly photographed."),
     TagInfo(0xa302, "CFAPattern", "Color Filter Array Pattern",
             "Indicates the color filter array (CFA) geometric pattern of the "
             "image sensor when a one-chip color area sensor is used. "
             "It does not apply to all sensing methods."),
     TagInfo(0xa401, "CustomRendered", "Custom Rendered",
             "This tag indicates the use of special processing on image "
             "data, such as rendering geared to output. When special "
             "processing is performed, the reader is expected to disable "
             "or minimize any further processing."),
     TagInfo(0xa402, "ExposureMode", "Exposure Mode",
             "This tag indicates the exposure mode set when the image was "
             "shot. In auto-bracketing mode, the camera shoots a series of "
             "frames of the same scene at different exposure settings."),
     TagInfo(0xa403, "WhiteBalance", "White Balance",
             "This tag indicates the white balance mode set when the image was shot."),
     TagInfo(0xa404, "DigitalZoomRatio", "Digital Zoom Ratio",
             "This tag indicates the digital zoom ratio when the image was "
             "shot. If the numerator of the recorded value is 0, this "
             "indicates that digital zoom was not used."),
     TagInfo(0xa405, "FocalLengthIn35mmFilm", "Focal Length In 35mm Film",
             "This tag indicates the equivalent focal length assuming a "
             "35mm film camera, in mm. A value of 0 means the focal "
             "length is unknown. Note that this tag differs from the "
             "<FocalLength> tag."),
     TagInfo(0xa406, "SceneCaptureType", "Scene Capture Type",
             "This tag indicates the type of scene that was shot. It can "
             "also be used to record the mode in which the image was "
             "shot. Note that this differs from the <SceneType> tag."),
     TagInfo(0xa407, "GainControl", "Gain Control",
             "This tag indicates the degree of overall image gain adjustment."),
     TagInfo(0xa408, "Contrast", "Contrast",
             "This tag indicates the direction of contrast processing "
             "applied by the camera when the image was shot."),
     TagInfo(0xa409, "Saturation", "Saturation",
             "This tag indicates the direction of saturation processing "
             "applied by the camera when the image was shot."),
     TagInfo(0xa40a, "Sharpness", "Sharpness",
             "This tag indicates the direction of sharpness processing "
             "applied by the camera when the image was shot."),
     TagInfo(0xa40b, "DeviceSettingDescription", "Device Setting Description",
             "This tag indicates information on the picture-taking "
             "conditions of a particular camera model. The tag is used "
             "only to indicate the picture-taking conditions in the reader."),
     TagInfo(0xa40c, "SubjectDistanceRange", "Subject Distance Range",
             "This tag indicates the distance to the subject."),
     TagInfo(0xa420, "ImageUniqueID", "Image Unique ID",
             "This tag indicates an identifier assigned uniquely to "
             "each image. It is recorded as an ASCII string equivalent "
             "to hexadecimal notation and 128-bit fixed length."),
     TagInfo(0xa430, "CameraOwnerName", "Camera Owner Name",
             "This tag records the owner of a camera used in "
             "photography as an ASCII string."),
     TagInfo(0xa431, "BodySerialNumber", "Body Serial Number",
             "This tag records the serial number of the body of the camera "
             "that was used in photography as an ASCII string."),
     TagInfo(0xa432, "LensSpecification", "Lens Specification",
             "This tag notes minimum focal length, maximum focal length, "
             "minimum F number in the minimum focal length, and minimum F number "
             "in the maximum focal length, which are specification information "
             "for the lens that was used in photography. When the minimum F "
             "number is unknown, the notation is 0/0"),
     TagInfo(0xa433, "LensMake", "Lens Make",
             "This tag records the lens manufactor as an ASCII string."),
     TagInfo(0xa434, "LensModel", "Lens Model",
             "This tag records the lens's model name and model number as an "
             "ASCII string."),
     TagInfo(0xa435, "LensSerialNumber", "Lens Serial Number",
             "This tag records the serial number of the interchangeable lens "
             "that was used in photography as an ASCII string."),

///< GPS INFO
    TagInfo(0x0000, "GPSVersionID", "GPS Version ID", "Indicates the version of <GPSInfoIFD>."),
    TagInfo(0x0001, "GPSLatitudeRef", "GPS Latitude Reference",
            "Indicates whether the latitude is north or south latitude."),
    TagInfo(0x0002, "GPSLatitude", "GPS Latitude",
            "Indicates the latitude."),
    TagInfo(0x0003, "GPSLongitudeRef", "GPS Longitude Reference",
            "Indicates whether the longitude is east or west longitude. "),
    TagInfo(0x0004, "GPSLongitude", "GPS Longitude",
            "Indicates the longitude."),
    TagInfo(0x0005, "GPSAltitudeRef", "GPS Altitude Reference",
            "Indicates the altitude used as the reference altitude."),
    TagInfo(0x0006, "GPSAltitude", "GPS Altitude",
            "Indicates the altitude based on the reference in GPSAltitudeRef. "),
    TagInfo(0x0007, "GPSTimeStamp", "GPS Time Stamp",
            "Indicates the time as UTC (Coordinated Universal Time). "),
    TagInfo(0x0008, "GPSSatellites", "GPS Satellites",
            "Indicates the GPS satellites used for measurements. "),
    TagInfo(0x0009, "GPSStatus", "GPS Status",
            "Indicates the status of the GPS receiver when the image is recorded. "),
    TagInfo(0x000a, "GPSMeasureMode","GPS Measure Mode",
            "Indicates the GPS measurement mode. \"2\" means two-dimensional measurement and \"3\" "
            "means three-dimensional measurement is in progress."),
    TagInfo(0x000b, "GPSDOP", "GPS Data Degree of Precision",
             "Indicates the GPS DOP (data degree of precision). An HDOP value is written "),
    TagInfo(0x000c, "GPSSpeedRef", "GPS Speed Reference",
            "Indicates the unit used to express the GPS receiver speed of movement. "),
    TagInfo(0x000d, "GPSSpeed","GPS Speed",
            "Indicates the speed of GPS receiver movement."),
    TagInfo(0x000e, "GPSTrackRef", "GPS Track Ref",
            "Indicates the reference for giving the direction of GPS receiver movement. "),
    TagInfo(0x000f, "GPSTrack", "GPS Track",
            "Indicates the direction of GPS receiver movement."),
    TagInfo(0x0010, "GPSImgDirectionRef", "GPS Image Direction Reference",
            "Indicates the reference for giving the direction of the image when it is captured. "),
    TagInfo(0x0011, "GPSImgDirection", "GPS Image Direction",
            "Indicates the direction of the image when it was captured."),
    TagInfo(0x0012, "GPSMapDatum", "GPS Map Datum",
            "Indicates the geodetic survey data used by the GPS receiver."),
    TagInfo(0x0013, "GPSDestLatitudeRef", "GPS Destination Latitude Reference",
            "Indicates whether the latitude of the destination point is north or south latitude. "),
    TagInfo(0x0014, "GPSDestLatitude", "GPS Destination Latitude",
            "Indicates the latitude of the destination point. The latitude is expressed as "
            "three RATIONAL values giving the degrees, minutes, and seconds, respectively. "),
    TagInfo(0x0015, "GPSDestLongitudeRef", "GPS Destination Longitude Reference",
            "Indicates whether the longitude of the destination point is east or west longitude. "),
    TagInfo(0x0016, "GPSDestLongitude", "GPS Destination Longitude",
            "Indicates the longitude of the destination point."),
    TagInfo(0x0017, "GPSDestBearingRef", "GPS Destination Bearing Reference",
            "Indicates the reference used for giving the bearing to the destination point. "),
    TagInfo(0x0018, "GPSDestBearing", "GPS Destination Bearing",
            "Indicates the bearing to the destination point."),
    TagInfo(0x0019, "GPSDestDistanceRef", "GPS Destination Distance Reference",
            "Indicates the unit used to express the distance to the destination point. "),
    TagInfo(0x001a, "GPSDestDistance", "GPS Destination Distance",
            "Indicates the distance to the destination point."),
    TagInfo(0x001b, "GPSProcessingMethod", "GPS Processing Method",
            "A character string recording the name of the method used for location finding. "),
    TagInfo(0x001c, "GPSAreaInformation", "GPS Area Information",
            "A character string recording the name of the GPS area. The first byte indicates "),
    TagInfo(0x001d, "GPSDateStamp", "GPS Date Stamp",
            "A character string recording date and time information relative to UTC (Coordinated Universal Time)."),
    TagInfo(0x001e, "GPSDifferential","GPS Differential",
            "Indicates whether differential correction is applied to the GPS receiver."),
};

@implementation ExifData

+ (instancetype)initWithOriginName:(const char *) originName
                       originValue:(const char *) originValue
{
    NSString *splitString = [NSString stringWithFormat:@"%s", originName];
    NSArray *splitArray = [splitString componentsSeparatedByString:@"."];
    if (splitArray.count == 3 && [splitArray[1] isEqualToString:@"Thumbnail"]) {
        return nil;
    }
    NSString *lastString = [splitArray lastObject];
    NSString *description = nil;
    NSString *convertName = [self convertOriginNameToReadableName:lastString.UTF8String
                                                      description:&description];
    if (convertName == nil) {
        return nil;
    }
    ExifData *newExifData = [[ExifData alloc] init];
    newExifData.dataName = convertName;
    newExifData.dataDescription = description;
    newExifData.dataValue = [NSString stringWithFormat:@"%s", originValue];

    return newExifData;
}

+ (NSString *)convertOriginNameToReadableName:(const char *) originName
                                  description:(NSString **) description
{
    for (uint32_t i = 0; i < kTagArrayCount; i++) {
        const TagInfo &tagInfo = kTagInfoArray[i];
        if (strcmp(originName, tagInfo.name_) == 0) {
            NSString *resultString = [NSString stringWithFormat:@"%s", tagInfo.title_];
            *description = [NSString stringWithFormat:@"%s", tagInfo.description_];
            return resultString;
        }
    }
    return nil;
}

@end
