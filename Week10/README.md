# Week 10 Assignment: Variant Calling Pipeline

# Week 10 Command Log for Makefile

Datasets:
| Source                  | Sample Description    | Sample ID     | SRR Accession |
| :---------------------- | :-------------------- | :------------ | :------------ |
| BioProject PRJNA887926  | Control Replicate 1   |  SRS15348645  | SRR21835898   |
|                         | Control Replicate 2   |  SRS15348646  | SRR21835897   |
|                         | Control Replicate 3   |  SRS15348647  | SRR21835896   |
|                         | Treatment Replicate 1 |  SRS15348642  | SRR21835901   |
|                         | Treatment Replicate 2 |  SRS15348643  | SRR21835900   |
|                         | Treatment Replicate 3 |  SRS15348644  | SRR21835899   |

## File Structure

* Makefile - Single-sample processing (parameterized for one sample at a time)
* Looper.mk - Batch processing wrapper (loops over all samples in design.csv)
* design.csv - User-created file listing samples to process (format: Run,Sample)
* metadata/design.csv - Auto-generated from SRA metadata download


